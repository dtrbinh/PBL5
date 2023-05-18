import 'package:appmobile/models/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  var server = '192.168.53.214';
  List<Log> logList = [];
  var isLoaded = false;

  Future<void> getAllLogs() async {
    var url = Uri.http(server, '/logs');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body) as List<dynamic>;

      List<Log> logs = responseData.map((data) {
        return Log(
            id: data['id'].toString(),
            imageCheckIn: data['img_check_in'],
            numberPlate: data['number_plate'],
            studentId: data['student_id'],
            imageCheckOut: data['img_check_out'],
            timeCheckIn: DateTime.parse(data['time_check_in']).toString(),
            timeCheckOut: DateTime.parse(data['time_check_out']).toString());
      }).toList();

      setState(() {
        isLoaded = true;
        logList = logs;
        debugPrint("$logs");
      });
    } else {
      debugPrint(
          'Failed to fetch check-ins. Status code: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    getAllLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử checkin, checkout'),
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
                final logItem = logList[index];
                return ListTile(
                  title: Text(
                    'Mã số sinh viên: ${logItem.studentId} \nBiển số xe: ${logItem.numberPlate}',
                  ),
                  subtitle: Text(
                    "Thời gian check-in: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(logItem.timeCheckIn!))}\n Thời gian checkout: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(logItem.timeCheckOut!))}",
                  ),
                  onTap: () {},
                );
              },
              separatorBuilder: (context, index) => Divider(
                thickness: 3.0,
              ), // Add Divider between items
              itemCount: logList.length,
            ),
    );
  }
}
