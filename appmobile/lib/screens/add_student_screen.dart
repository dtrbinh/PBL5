import 'dart:convert';
import 'dart:io';

import 'package:appmobile/models/student.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AddStudentScreen extends StatelessWidget {
  final Function onStudentAdded;

  AddStudentScreen({required this.onStudentAdded});

  var server = '192.168.53.214';

  TextEditingController _id = TextEditingController();

  TextEditingController _name = TextEditingController();

  TextEditingController _className = TextEditingController();

  TextEditingController _faculty = TextEditingController();

  Future<void> addStudent(
      String id, String name, String className, String faculty) async {
    var url = Uri.http(server, '/students');
    var headers = {'Content-Type': 'application/json'};
    var body = json.encode({
      'id': id,
      'name': name,
      'class_name': className,
      'faculty': faculty,
    });

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201) {
      Fluttertoast.showToast(
        msg: "Thêm sinh viên thành công",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Thêm sinh viên thất bại",
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
        title: Text('My Screen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              controller: _id,
              decoration: InputDecoration(
                labelText: 'ID',
              ),
            ),
            TextField(
              controller: _name,
              decoration: InputDecoration(
                labelText: 'Họ tên',
              ),
            ),
            TextField(
              controller: _className,
              decoration: InputDecoration(
                labelText: 'Lớp',
              ),
            ),
            TextField(
              controller: _faculty,
              decoration: InputDecoration(
                labelText: 'Khoa',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Handle button press
                String id = _id.text;
                String name = _name.text;
                String className = _className.text;
                String faculty = _faculty.text;
                // Do something with the entered values
                addStudent(id, name, className, faculty);
                onStudentAdded();
                Navigator.pop(context);
              },
              child: Text('Thêm sinh viên'),
            ),
          ],
        ),
      ),
    );
  }
}
