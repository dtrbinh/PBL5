import 'package:appmobile/models/checkout.dart';
import 'package:appmobile/models/log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class EditCheckoutScreen extends StatefulWidget {
  final Log log;
  const EditCheckoutScreen({required this.log});

  @override
  State<EditCheckoutScreen> createState() => _EditCheckoutScreenState();
}

class _EditCheckoutScreenState extends State<EditCheckoutScreen> {
  late TextEditingController numberPlateController;
  late TextEditingController studentIdController;
  late TextEditingController timeCheckInController;
  late TextEditingController timeCheckOutController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    numberPlateController = TextEditingController(text: widget.log.numberPlate);
    studentIdController = TextEditingController(text: widget.log.studentId);
    timeCheckInController = TextEditingController(text: widget.log.timeCheckIn);
    timeCheckOutController =
        TextEditingController(text: widget.log.timeCheckOut);
  }

  @override
  Widget build(BuildContext context) {
    final updatedNumberPlate = numberPlateController.text.toString();
    final updatedStudentId = studentIdController.text.toString();
    final updatedTimeCheckIn = timeCheckInController.text.toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết lịch sử check-in, check-out'),
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
                controller: studentIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'MSSV',
                    labelStyle:
                        TextStyle(fontSize: 20, color: Colors.blueGrey)),
              ),
              TextField(
                enabled: false,
                controller: numberPlateController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    labelText: 'Biển số xe',
                    labelStyle:
                        TextStyle(fontSize: 20, color: Colors.blueGrey)),
              ),
              TextField(
                enabled: false,
                controller: timeCheckInController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    labelText: 'Thời gian check-in',
                    labelStyle:
                        TextStyle(fontSize: 20, color: Colors.blueGrey)),
              ),
              TextField(
                enabled: false,
                controller: timeCheckOutController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    labelText: 'Thời gian check-out',
                    labelStyle:
                        TextStyle(fontSize: 20, color: Colors.blueGrey)),
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
