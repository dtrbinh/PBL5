import 'dart:convert';

import 'package:appmobile/models/checkout.dart';
import 'package:appmobile/models/log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;

import '../util/constants.dart';

class EditCheckoutScreen extends StatefulWidget {
  final Log log;
  const EditCheckoutScreen({required this.log});

  @override
  State<EditCheckoutScreen> createState() => _EditCheckoutScreenState();
}

class _EditCheckoutScreenState extends State<EditCheckoutScreen> {
  late TextEditingController idController;
  late TextEditingController numberPlateController;
  late TextEditingController studentIdController;
  late TextEditingController timeCheckInController;
  late TextEditingController timeCheckOutController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    idController = TextEditingController(text: widget.log.id);
    numberPlateController = TextEditingController(text: widget.log.numberPlate);
    studentIdController = TextEditingController(text: widget.log.studentId);
    timeCheckInController = TextEditingController(text: widget.log.timeCheckIn);
    timeCheckOutController =
        TextEditingController(text: widget.log.timeCheckOut);
  }

  Future<void> updateLog(Log log) async {
    final id = idController.text.toString();
    final updatedNumberPlate = numberPlateController.text.toString();
    final updatedStudentId = studentIdController.text.toString();
    final updatedTimeCheckIn = timeCheckInController.text.toString();
    final updatedTimeCheckOut = timeCheckOutController.text.toString();

    var url = Uri.http(Constant.server, '/logs/$id');

    // Tạo body request từ thông tin cần cập nhật
    final body = json.encode({
      'img_check_in': log.imageCheckIn,
      'img_check_out': log.imageCheckOut,
      'number_plate': updatedNumberPlate,
      'student_id': updatedStudentId,
      'time_check_in': updatedTimeCheckIn,
      'time_check_out': updatedTimeCheckOut
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
    final id = idController.text.toString();
    final updatedNumberPlate = numberPlateController.text.toString();
    final updatedStudentId = studentIdController.text.toString();
    final updatedTimeCheckIn = timeCheckInController.text.toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết lịch sử '),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                enabled: false,
                controller: idController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'ID',
                    labelStyle:
                        TextStyle(fontSize: 20, color: Colors.blueGrey)),
              ),
              TextField(
                controller: studentIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'MSSV',
                    labelStyle:
                        TextStyle(fontSize: 20, color: Colors.blueGrey)),
              ),
              TextField(
                controller: numberPlateController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    labelText: 'Biển số xe',
                    labelStyle:
                        TextStyle(fontSize: 20, color: Colors.blueGrey)),
              ),
              TextField(
                controller: timeCheckInController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    labelText: 'Thời gian check-in',
                    labelStyle:
                        TextStyle(fontSize: 20, color: Colors.blueGrey)),
              ),
              TextField(
                controller: timeCheckOutController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    labelText: 'Thời gian check-out',
                    labelStyle:
                        TextStyle(fontSize: 20, color: Colors.blueGrey)),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: (() {
                  updateLog(widget.log);
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
                height: 20,
              ),

              Image.network(
                widget.log.imageCheckIn!,
                height: 400, // Adjust the height to your desired size
                fit: BoxFit.cover, // Adjust the image fit as needed
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Ảnh check-in",
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(
                height: 20,
              ),

              Image.network(
                widget.log.imageCheckOut!,
                height: 400, // Adjust the height to your desired size
                fit: BoxFit.cover, // Adjust the image fit as needed
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Ảnh check-out",
                style: TextStyle(fontSize: 16),
              ),
              // ElevatedButton(
              //   onPressed: (() {
              //     updateCheckIn(updatedNumberPlate, updatedStudentId);
              //     Navigator.popUntil(context, (route) => route.isCurrent);
              //     Navigator.pop(context);
              //   }),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.teal,
              //     fixedSize: const Size.fromWidth(120),
              //   ),
              //   child: const Text('Cập nhật'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
