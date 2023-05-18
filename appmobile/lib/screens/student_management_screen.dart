import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class StudentManagement extends StatefulWidget {
  const StudentManagement({super.key});

  @override
  State<StudentManagement> createState() => _StudentManagementState();
}

class _StudentManagementState extends State<StudentManagement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý sinh viên'),
      ),
      body: Center(
        child: Text('QLSV.'),
      ),
    );
  }
}
