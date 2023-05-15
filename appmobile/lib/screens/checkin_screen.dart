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

  File? cardImageCheckout;
  File? motorbikeImageCheckout;

  var isCardLoading = false;
  var isMotorbikeLoading = false;
  var isCheckout = false;

  Future<void> _takeStudentCardPicture() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (imageFile == null) {
      return;
    }
    final imagePermanent = await saveFilePermanently(imageFile.path);
    setState(() {
      cardImageCheckout = File(imagePermanent.path);
      student.studentData!.id = '19';
    });
  }

  Future<File> saveFilePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');
    return File(imagePath).copy(image.path);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10, top: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _takeStudentCardPicture,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  fixedSize: const Size.fromWidth(120),
                  padding: const EdgeInsets.all(10),
                ),
                child: const Text('Chụp thẻ sv'),
              ),
              cardImageCheckout == null
                  ? Text('Chua chup the sv')
                  : Image.file(
                      cardImageCheckout as File,
                      width: 350,
                      height: 350,
                    ),
              Text('check in screen'),
            ],
          ),
        ),
      ],
    );
  }
}
