import 'dart:convert';

import 'package:appmobile/screens/student_management_screen.dart';
import 'package:flutter/material.dart';

import '../models/student.dart';

import 'package:http/http.dart' as http;

class EditStudentScreen extends StatefulWidget {
  final StudentData studentData;

  const EditStudentScreen({required this.studentData});

  @override
  _EditStudentScreenState createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  late TextEditingController idController;
  late TextEditingController nameController;
  late TextEditingController classController;
  late TextEditingController facultyController;

  var server = '192.168.53.214';

  @override
  void initState() {
    super.initState();
    idController = TextEditingController(text: widget.studentData.id);
    nameController = TextEditingController(text: widget.studentData.name);
    classController =
        TextEditingController(text: widget.studentData.studentClass);
    facultyController = TextEditingController(text: widget.studentData.faculty);
  }

  @override
  void dispose() {
    idController.dispose();
    nameController.dispose();
    classController.dispose();
    facultyController.dispose();
    super.dispose();
  }

  Future<void> updateStudent(BuildContext context) async {
    final updatedId = idController.text;
    final updatedName = nameController.text;
    final updatedClass = classController.text;
    final updatedFaculty = facultyController.text;
    var url = Uri.http(server, '/students/$updatedId');
    var body = json.encode({
      'name': updatedName,
      'class_name': updatedClass,
      'faculty': updatedFaculty,
    });
    var headers = {'Content-Type': 'application/json'};

    debugPrint("$updatedName");
    var response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Successful update
      debugPrint('Student updated successfully');
    } else {
      debugPrint(
          'Failed to update student. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final updatedId = idController.text;
    final updatedName = nameController.text;
    final updatedClass = classController.text;
    final updatedFaculty = facultyController.text;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật thông tin sinh viên'),
        centerTitle: true,
        backgroundColor: Colors.cyan,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: idController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ID',
              ),
            ),
            TextField(
              controller: nameController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextField(
              controller: classController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Class',
              ),
            ),
            TextField(
              controller: facultyController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Faculty',
              ),
            ),
            ElevatedButton(
              onPressed: (() {
                updateStudent(context);
                Navigator.pop(context);
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                fixedSize: const Size.fromWidth(120),
              ),
              child: const Text('Cập nhật'),
            ),
          ],
        ),
      ),
    );
  }
}
