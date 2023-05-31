import 'package:appmobile/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'main2.dart';

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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
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
            const SizedBox(
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
