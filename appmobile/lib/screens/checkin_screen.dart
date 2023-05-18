import 'dart:convert';
import 'dart:io';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import '../models/motorbike.dart';
import '../models/student.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _ImageInputState();
}

class _ImageInputState extends State<CheckInScreen> {
  var student = Student(
    message: '',
    studentData: StudentData(
      id: 'Không xác định',
      name: 'Không xác định',
      studentClass: 'Không xác định',
      faculty: 'Không xác định',
    ),
    status: 0,
  );

  var motorbike = Motorbike(
    numberPlate: 'Không xác định',
    message: 'Nhận diện thất bại',
    status: 0,
    plateImage: 'Không xác định',
  );

  File? cardImageCheckin;
  File? motorbikeImageCheckin;

  var isCardLoading = false;
  var isMotorbikeLoading = false;
  var isCheckIn = false;

  var server = '192.168.53.214';

  Future<void> _takeStudentCardPicture() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (imageFile == null) {
      return;
    }

    setState(() {
      cardImageCheckin = File(imageFile.path);
      isCardLoading = true;
    });

    uploadCardImage(cardImageCheckin!).then((_) {
      setState(() {
        isCardLoading = false;
      });
    });
  }

  Future<void> uploadCardImage(File imageFile) async {
    var url = Uri.http(server, '/students/scan-card');
    var request = http.MultipartRequest('POST', url);

    var multipartFile =
        await http.MultipartFile.fromPath('student_card_img', imageFile.path);
    request.files.add(multipartFile);

    var response = await request.send();
    debugPrint("${response.statusCode}");
    if (response.statusCode == 201) {
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      Map<String, dynamic> responseMap = json.decode(responseData);
      StudentData studentData = StudentData(
        id: responseMap['data']['student_id'],
        name: responseMap['data']['name'],
        studentClass: responseMap['data']['class_name'],
        faculty: responseMap['data']['faculty'],
      );

      setState(() {
        student = Student(
          message: responseMap['message'],
          studentData: studentData,
          status: responseMap['status'],
        );
      });
    } else {
      setState(() {
        student = Student(
          message: '',
          studentData: StudentData(
            id: 'Không xác định',
            name: 'Không xác định',
            studentClass: 'Không xác định',
            faculty: 'Không xác định',
          ),
          status: 0,
        );
      });
    }
  }

  Future<void> _takeMotorbikePicture() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (imageFile == null) {
      return;
    }
    final imagePermanent = await saveFilePermanently(imageFile.path);

    final decodedImage = img.decodeImage(imagePermanent.readAsBytesSync())!;
    final resizedImage = img.copyResize(decodedImage, width: 640, height: 640);
    final resizedImageFile = await saveResizedImagePermanently(resizedImage);
    setState(() {
      motorbikeImageCheckin = File(resizedImageFile.path);
      isMotorbikeLoading = true;
    });

    uploadMotorbikeImage(motorbikeImageCheckin!).then((_) {
      setState(() {
        isMotorbikeLoading = false;
      });
    });
  }

  Future<File> saveResizedImagePermanently(img.Image image) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '$tempPath/$timestamp.jpg';
    final resizedFile = File(filePath);
    resizedFile.writeAsBytesSync(img.encodeJpg(image, quality: 90));
    return resizedFile;
  }

  Future<File> saveFilePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');
    return File(imagePath).copy(image.path);
  }

  Future<void> uploadMotorbikeImage(File imageFile) async {
    var url = Uri.http(server, '/plates/read-plate-text');
    var request = http.MultipartRequest('POST', url);

    var multipartFile =
        await http.MultipartFile.fromPath('plate_img', imageFile.path);
    request.files.add(multipartFile);

    var response = await request.send();

    if (response.statusCode == 201) {
      debugPrint('Image uploaded successfully');
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      debugPrint(responseData);
      Map<String, dynamic> responseMap = json.decode(responseData);
      setState(() {
        motorbike = Motorbike(
          numberPlate: responseMap['data']['number_plate'],
          message: responseMap['message'],
          status: responseMap['status'],
          plateImage: responseMap['data']['plate_img'],
        );
      });
      debugPrint("${responseMap['data']['plate_img']}");
    } else {
      setState(() {
        motorbike = Motorbike(
          numberPlate: 'Không xác định',
          message: 'Không xác định',
          status: 0,
          plateImage: 'Không xác định',
        );
      });
      debugPrint('Image upload failed with status: ${response.statusCode}');
    }
  }

  Future<void> checkIn(
      String plateNumber, String studentId, String imageFile) async {
    var url = Uri.http(server, '/check-ins');

    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({
      'number_plate': plateNumber,
      'student_id': studentId,
      'img_check_in': imageFile,
    });

    var response = await http.post(url, headers: headers, body: body);
    debugPrint("${response.statusCode}");
    if (motorbike.status == 0 || student.status == 0) {
      setState(() {
        isCheckIn = false;
      });
      Fluttertoast.showToast(
        msg: "Check-in thất bại",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    if (response.statusCode == 201) {
      // Handle successful response
      var responseBody = response.body;
      debugPrint("${responseBody}");
      var jsonBody = jsonDecode(responseBody);
      var checkInData = jsonBody['data'];
      // var message = jsonBody['message'];
      var message = "Check-in thành công";
      print('Check-in success: $message');
      print('Check-in data: $checkInData');
      Fluttertoast.showToast(
        msg: "${message}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        isCheckIn = true;
      });
    } else {
      // Handle error response
      var responseBody = response.body;
      debugPrint("${responseBody}");
      var jsonBody = jsonDecode(responseBody);
      var message = "Check-in thất bại";
      setState(() {
        isCheckIn = false;
      });
      Fluttertoast.showToast(
        msg: "${message}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print('Check-in failed with status: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (isCardLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else
          Container(
            margin: const EdgeInsets.only(left: 20, bottom: 10, top: 20),
            // flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Thông tin sinh viên',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  'ID: ${student.studentData?.id}',
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Khoa: ${student.studentData?.faculty}',
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Lớp: ${student.studentData?.studentClass}',
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Họ tên: ${student.studentData?.name}',
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 8.0),
                student.status == 1
                    ? const Text(
                        'Trạng thái: Nhận diện thành công',
                        style: TextStyle(fontSize: 18.0),
                      )
                    : const Text(
                        'Trạng thái: Nhận diện thất bại',
                        style: TextStyle(fontSize: 18.0),
                      ),
              ],
            ),
          ),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _takeStudentCardPicture,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  fixedSize: const Size.fromWidth(120),
                ),
                child: const Text(
                  'Chụp thẻ SV',
                ),
              ),
            ],
          ),
        ),
        if (isMotorbikeLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin biển số xe',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  'Biển số xe: ${motorbike.numberPlate}',
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 10.0),
                motorbike.status == 1
                    ? const Text(
                        'Trạng thái: Nhận diện thành công',
                        style: TextStyle(fontSize: 18.0),
                      )
                    : const Text(
                        'Trạng thái: Nhận diện thất bại',
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
              ],
            ),
          ),
        Container(
          margin: const EdgeInsets.only(left: 10, top: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _takeMotorbikePicture,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  fixedSize: const Size.fromWidth(120),
                  padding: const EdgeInsets.all(10),
                ),
                child: const Text('Chụp biển số xe'),
              ),
              ElevatedButton(
                onPressed: (() => checkIn(
                      motorbike.numberPlate!,
                      student.studentData!.id,
                      motorbike.plateImage!,
                    )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  fixedSize: const Size.fromWidth(120),
                  padding: const EdgeInsets.all(10),
                ),
                child: const Text('Check-in'),
              ),
              !isCheckIn
                  ? const Text(
                      "Check-in thất bại",
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    )
                  : const Text(
                      "Check-in thành công",
                      style: TextStyle(color: Colors.green, fontSize: 18),
                    )
            ],
          ),
        ),
      ],
    );
  }
}
