import 'package:appmobile/screens/SecondScreen.dart';
import 'package:appmobile/screens/manage_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý nhà xe'),
          centerTitle: true,
          backgroundColor: Colors.blueGrey,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
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
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    fixedSize: const Size.fromWidth(95),
                  ),
                  child: const Text('Nghiệp vụ'),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManagerScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    fixedSize: const Size.fromWidth(95),
                  ),
                  child: const Text('Quản lý'),
                ),
              ]),
            ),
            const SizedBox(
              height: 50,
            )
          ],
        ));
  }
}
