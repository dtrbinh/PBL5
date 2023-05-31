import 'dart:convert';

import 'package:appmobile/models/checkin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;

import '../util/constants.dart';

class EditCheckinScreen extends StatefulWidget {
  final CheckIn checkIn;
  const EditCheckinScreen({required this.checkIn});

  @override
  State<EditCheckinScreen> createState() => _CheckInDetailScreenState();
}

class _CheckInDetailScreenState extends State<EditCheckinScreen> {
  late TextEditingController idController;
  late TextEditingController numberPlateController;
  late TextEditingController studentIdController;
  late TextEditingController timeCheckInController;

  @override
  void initState() {
    super.initState();
    idController = TextEditingController(text: widget.checkIn.id);
    numberPlateController =
        TextEditingController(text: widget.checkIn.numberPlate);
    studentIdController = TextEditingController(text: widget.checkIn.studentId);
    timeCheckInController =
        TextEditingController(text: widget.checkIn.timeCheckIn);
  }

  @override
  void dispose() {
    numberPlateController.dispose();
    studentIdController.dispose();
    timeCheckInController.dispose();
    super.dispose();
  }

  Future<void> updateCheckIn(CheckIn checkIn) async {
    final id = idController.text.toString();
    final updatedNumberPlate = numberPlateController.text.toString();
    final updatedStudentId = studentIdController.text.toString();
    var url = Uri.http(Constant.server, '/check-ins/$id');

    // Tạo body request từ thông tin cần cập nhật
    final body = json.encode({
      'img_check_in': checkIn.imageCheckIn,
      'number_plate': updatedNumberPlate,
      'student_id': updatedStudentId,
    });
    var headers = {'Content-Type': 'application/json'};

    var response = await http.put(
      url,
      headers: headers,
      body: body,
    );

    debugPrint("updatedNumberplate: $updatedNumberPlate");

    if (response.statusCode == 200) {
      // Cập nhật thành công
      print('Check-in đã được cập nhật thành công');
      Fluttertoast.showToast(
        msg: "Cập nhật check-in thành công",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      // Cập nhật thất bại
      print('Cập nhật check-in thất bại. Mã lỗi: ${response.statusCode}');
      var responseBody = response.body;
      debugPrint("${responseBody}");
      var jsonBody = jsonDecode(responseBody);
      var message = jsonBody['message'];
      debugPrint("message: $message");
      Fluttertoast.showToast(
        msg: "Cập nhật check-in thất bại",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Check-in'),
        centerTitle: true,
        backgroundColor: Colors.cyan,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                enabled: false,
                controller: idController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'ID',
                ),
              ),
              TextField(
                controller: numberPlateController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Biển số xe',
                ),
              ),
              TextField(
                controller: studentIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'MSSV',
                ),
              ),
              TextField(
                enabled: false,
                controller: timeCheckInController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Thời gian check-in',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: (() {
                  updateCheckIn(widget.checkIn);
                  Navigator.popUntil(context, (route) => route.isCurrent);
                  Navigator.pop(context);
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  fixedSize: const Size.fromWidth(120),
                ),
                child: const Text('Cập nhật'),
              ),
              const SizedBox(
                height: 10,
              ),
              Image.network(
                widget.checkIn.imageCheckIn!,
                height: 400, // Adjust the height to your desired size
                fit: BoxFit.cover, // Adjust the image fit as needed
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Ảnh check-in",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
