import 'package:appmobile/type_server_screen_admin.dart';
import 'package:appmobile/screens/SecondScreen.dart';
import 'package:appmobile/type_server_screen_employee.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formfield = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool passwordToggle = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng nhập'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Form(
            key: _formfield,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/avatar.png",
                  height: 200,
                  width: 200,
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  validator: (value) {
                    bool emailValid = RegExp(
                            r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$')
                        .hasMatch(value!);
                    if (value.isEmpty) {
                      return "Hãy nhập email";
                    } else if (!emailValid) {
                      return "Hãy nhập email hợp lệ";
                    }
                  },
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email)),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Hãy nhập mật khẩu";
                    } else if (passwordController.text.length < 6) {
                      return "Mật khẩu phải hơn 6 ký tự";
                    }
                  },
                  keyboardType: TextInputType.emailAddress,
                  controller: passwordController,
                  obscureText: passwordToggle,
                  decoration: InputDecoration(
                    labelText: "Mật khẩu",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: InkWell(
                      onTap: (() {
                        setState(() {
                          passwordToggle = !passwordToggle;
                        });
                      }),
                      child: Icon(passwordToggle
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () {
                    if (_formfield.currentState!.validate()) {
                      String email = emailController.text.toString();
                      String password = passwordController.text.toString();

                      if (email == 'admin@gmail.com' && password == '123456') {
                        // Navigate to AdminScreen
                        Fluttertoast.showToast(
                          msg: "Đăng nhập thành công",
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FirstScreen()),
                        );
                      } else if (email == 'nhanvien@gmail.com' &&
                          password == '123456') {
                        Fluttertoast.showToast(
                          msg: "Đăng nhập thành công",
                        );
                        // Navigate to EmployeeScreen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EmployeeScreen()),
                        );
                      } else {
                        // Invalid credentials, show an error message
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Không hợp lệ'),
                              content: Text(
                                  'Bạn đã nhập sai email hoặc mật khẩu. Vui lòng nhập lại'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                      debugPrint("success");
                      // emailController.clear();
                      // passwordController.clear();
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Center(
                      child: Text(
                        "Đăng nhập",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
