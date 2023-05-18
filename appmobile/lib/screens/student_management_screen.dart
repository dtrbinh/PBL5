import 'package:appmobile/models/student.dart';
import 'package:appmobile/screens/add_student_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'edit_student_screen.dart';

class StudentManagement extends StatefulWidget {
  const StudentManagement({super.key});

  @override
  State<StudentManagement> createState() => _StudentManagementState();
}

class _StudentManagementState extends State<StudentManagement> {
  var server = '192.168.53.214';
  List<Student> studentList = [];
  var isLoaded = false;

  Future<void> getAllLogs() async {
    var url = Uri.http(server, '/students');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body) as List<dynamic>;

      List<Student> students = responseData.map((data) {
        StudentData studentData = StudentData(
          id: data['id'],
          name: data['name'],
          studentClass: data['class_name'],
          faculty: data['faculty'],
        );
        return Student(
          message: '',
          status: 1,
          studentData: studentData,
        );
      }).toList();

      setState(() {
        isLoaded = true;
        studentList = students;
        debugPrint("$students");
      });
    } else {
      debugPrint(
          'Failed to fetch check-ins. Status code: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sinh viên'),
        centerTitle: true,
        backgroundColor: Colors.cyan,
      ),
      body: !isLoaded
          ? const Center(
              child:
                  CircularProgressIndicator(), // Show CircularProgressIndicator when loading
            )
          : ListView.separated(
              itemBuilder: (context, index) {
                final studentItem = studentList[index];
                return ListTile(
                  title: Text(
                    'Mã số sinh viên: ${studentItem.studentData!.id} \nHọ và tên: ${studentItem.studentData!.name}\nLớp: ${studentItem.studentData!.studentClass}\nKhoa: ${studentItem.studentData!.faculty}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditStudentScreen(
                          studentData: studentItem.studentData!,
                        ),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (context, index) => const Divider(
                thickness: 3.0,
              ), // Add Divider between items
              itemCount: studentList.length,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddStudentScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
