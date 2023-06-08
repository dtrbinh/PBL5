import 'package:appmobile/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'main2.dart';

import 'package:http/http.dart' as http;

class FirstScreen extends StatefulWidget {
  FirstScreen({Key? key}) : super(key: key);

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  TextEditingController serverController = TextEditingController();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    loadSavedData();
  }

  Future<void> loadSavedData() async {
    _prefs = await SharedPreferences.getInstance();
    String serverAddress = _prefs.getString('serverAddress') ?? '';
    setState(() {
      serverController.text = serverAddress;
      Constant.server = serverAddress;
    });
  }

  Future<void> saveData() async {
    await _prefs.setString('serverAddress', serverController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý nhà xe'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Đăng xuất'),
                    content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Dismiss the dialog
                        },
                        child: const Text('Không'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                            (route) =>
                                false, // Remove all previous routes from the stack
                          );
                        },
                        child: const Text('Có'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              const SizedBox(width: 30),
              Image.asset(
                "assets/AnhTruong.jpg",
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 30),
              Image.asset(
                "assets/AnhKhoa.jpg",
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
            child: TextField(
              controller: serverController,
              decoration: const InputDecoration(
                hintText: 'Nhập địa chỉ server',
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              // Handle button press
              FocusScope.of(context).unfocus();
              String ipAddress = serverController.text.toString();
              setState(() {
                Constant.server = ipAddress;
              });
              try {
                final response = await http
                    .get(Uri.http(ipAddress, '/students'))
                    .timeout(Duration(seconds: 3));
                if (response.statusCode == 200) {
                  _prefs.setString('serverAddress', ipAddress);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SplashScreen()),
                  );
                  Fluttertoast.showToast(msg: 'Đã nhập đúng server');
                } else if (response.statusCode != 200) {
                  Fluttertoast.showToast(
                      msg: 'Lỗi: Không thể kết nối đến endpoint /students');
                }
              } catch (e) {
                Fluttertoast.showToast(
                    msg: 'Lỗi: Không thể kết nối đến server');
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

  @override
  void dispose() {
    saveData();
    super.dispose();
  }
}
