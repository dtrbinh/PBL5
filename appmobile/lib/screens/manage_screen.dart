import 'dart:convert';

import 'package:appmobile/screens/checkin_management_screen.dart';
import 'package:appmobile/screens/history_screen.dart';
import 'package:appmobile/screens/student_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        centerTitle: true,
        title: const Text('Quản lý nhà xe'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: (() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentManagement()),
                );
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                fixedSize: const Size.fromWidth(120),
              ),
              child: const Text(
                ' Quản lý \nsinh viên',
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            ElevatedButton(
              onPressed: (() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CheckInManagement()),
                );
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                fixedSize: const Size.fromWidth(120),
              ),
              child: const Text(
                ' Quản lý \nCheck-in',
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            ElevatedButton(
              onPressed: (() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()),
                );
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                fixedSize: const Size.fromWidth(120),
              ),
              child: const Text(
                'Xem lịch sử',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
