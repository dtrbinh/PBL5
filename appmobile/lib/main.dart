import 'package:appmobile/screens/SecondScreen.dart';
import 'package:appmobile/screens/manage_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstScreen(),
    );
  }
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        centerTitle: true,
        title: Text('Ứng dụng hỗ trợ đỗ xe thông minh'),
      ),
      body: Center(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              fixedSize: const Size.fromWidth(100),
            ),
            child: Text('Nhân viên'),
          ),
          SizedBox(
            width: 10,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManagerScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              fixedSize: const Size.fromWidth(100),
            ),
            child: Text('Quản lý'),
          ),
        ]),
      ),
    );
  }
}
