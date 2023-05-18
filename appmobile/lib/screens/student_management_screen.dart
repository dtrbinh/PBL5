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
  void _reloadData() {
    // Implement the logic to reload the data here
    // For example, you can call the API again to fetch the latest student data
    getAllLogs();
  }

  bool isReloading = false;
  Future<void> reloadData() async {
    // Add your data reloading logic here
    // For example, call your API to fetch updated data
    getAllLogs();

    // Simulating a delay of 2 seconds
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      // Update your data and set isReloading to false
      // For example, update studentList with the new data
      isReloading = false;
    });
  }

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

  Future<void> deleteStudent(String studentId) async {
    var url = Uri.http(server, '/students/$studentId');

    var response = await http.delete(url);

    if (response.statusCode == 200) {
      // Student deleted successfully
      debugPrint('Student deleted');
    } else {
      debugPrint(
          'Failed to delete student. Status code: ${response.statusCode}');
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
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            isReloading = true;
          });
          await reloadData();
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollEndNotification) {
              final metrics = notification.metrics;
              if (metrics.atEdge && metrics.pixels != 0) {
                setState(() {
                  isReloading = true;
                });
                reloadData();
              }
            }
            return false;
          },
          child: ListView.separated(
            itemBuilder: (context, index) {
              final studentItem = studentList[index];
              return Dismissible(
                key: Key(studentItem.studentData!.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 16.0),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  // Handle the delete action here
                  deleteStudent(studentItem.studentData!.id);
                  setState(() {
                    studentList.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã xoá sinh viên'),
                    ),
                  );
                },
                child: ListTile(
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
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(
              thickness: 3.0,
            ),
            itemCount: studentList.length,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddStudentScreen(
                onStudentAdded: _reloadData,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
