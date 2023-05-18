import 'dart:convert';

import 'package:appmobile/models/checkin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

class CheckInManagement extends StatefulWidget {
  const CheckInManagement({super.key});

  @override
  State<CheckInManagement> createState() => _CheckInManagementState();
}

class _CheckInManagementState extends State<CheckInManagement> {
  var server = '192.168.53.214';
  List<CheckIn> checkinList = [];
  var isLoaded = false;

  Future<void> getAllCheckIns() async {
    var url = Uri.http(server, '/check-ins');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body) as List<dynamic>;

      List<CheckIn> checkIns = responseData.map((data) {
        return CheckIn(
          id: data['id'].toString(),
          imageCheckIn: data['img_check_in'],
          numberPlate: data['number_plate'],
          studentId: data['student_id'],
          timeCheckIn: DateTime.parse(data['time_check_in']).toString(),
        );
      }).toList();

      setState(() {
        isLoaded = true;
        checkinList = checkIns;
        debugPrint("$checkIns");
      });
    } else {
      debugPrint(
          'Failed to fetch check-ins. Status code: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    getAllCheckIns();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử checkin'),
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
                final checkinItem = checkinList[index];
                return ListTile(
                  title: Text(
                    'Mã số sinh viên: ${checkinItem.studentId} \nBiển số xe: ${checkinItem.numberPlate}',
                  ),
                  subtitle: Text(
                    "Thời gian check-in: ${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(checkinItem.timeCheckIn!))}",
                  ),
                  onTap: () {},
                );
              },
              separatorBuilder: (context, index) => const Divider(
                thickness: 3.0,
              ), // Add Divider between items
              itemCount: checkinList.length,
            ),
    );
  }
}
