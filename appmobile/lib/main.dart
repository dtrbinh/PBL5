import 'package:appmobile/main2.dart';
import 'package:appmobile/screens/SecondScreen.dart';
import 'package:appmobile/screens/manage_screen.dart';
import 'package:appmobile/util/constants.dart';
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
  FirstScreen({super.key});
  TextEditingController serverController = TextEditingController();

  bool isValidIPAddress(String ipAddress) {
    final regex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    return regex.hasMatch(ipAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý nhà xe'),
        centerTitle: true,
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            const SizedBox(
              width: 30,
            ),
            Image.asset(
              "assets/AnhTruong.jpg",
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            ),
            SizedBox(
              width: 30,
            ),
            Image.asset(
              "assets/AnhKhoa.jpg",
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            ),
          ]),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 80),
            child: TextField(
              controller: serverController,
              decoration: const InputDecoration(
                hintText: 'Nhập địa chỉ server',
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Handle button press
              // Constant.server = serverController.text.toString();
              FocusScope.of(context).unfocus();
              String ipAddress = serverController.text.toString();
              if (isValidIPAddress(ipAddress)) {
                Fluttertoast.showToast(
                  msg: "Đã nhập đúng server",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey[600],
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SplashScreen()),
                );
              } else {
                Fluttertoast.showToast(
                  msg: "Nhập sai server, vui lòng nhập lại",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey[600],
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              fixedSize: const Size.fromWidth(100),
            ),
            child: const Text('Xác nhận'),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
