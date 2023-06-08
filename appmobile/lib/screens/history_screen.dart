import 'package:appmobile/models/log.dart';
import 'package:appmobile/screens/edit_checkout_screen.dart';
import 'package:appmobile/util/constants.dart';
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
  List<Log> logList = [];
  var isLoaded = false;

  Future<void> getAllLogs() async {
    var url = Uri.http(Constant.server, '/logs');
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
        logList = logs.reversed.toList();
        debugPrint("$logs");
      });
    } else {
      debugPrint(
          'Failed to fetch check-ins. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteLogItem(String logId) async {
    var url = Uri.http(Constant.server, '/logs/$logId');

    var response = await http.delete(url);

    if (response.statusCode == 200) {
      // Student deleted successfully
      debugPrint('Student deleted');
    } else {
      debugPrint(
          'Failed to delete student. Status code: ${response.statusCode}');
    }
  }

  void _reloadData() {
    getAllLogs();
  }

  bool isReloading = false;
  Future<void> reloadData() async {
    getAllLogs();

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      isReloading = false;
    });
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
        backgroundColor: Colors.blueGrey,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Perform the data reload here
          await reloadData();
        },
        child: ListView.separated(
          itemBuilder: (context, index) {
            final logItem = logList[index];
            return Dismissible(
              key: Key(logItem.id!), // Unique key for each item
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                // Show confirmation dialog
                bool confirm = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Xác nhận xoá'),
                      content: Text('Bạn có chắc chắn muốn xoá lịch sử này?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(
                                false); // Dismiss the dialog and return false
                          },
                          child: Text('Không'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(
                                true); // Dismiss the dialog and return true
                          },
                          child: Text('Có'),
                        ),
                      ],
                    );
                  },
                );

                // Return the confirmation result
                return confirm ?? false;
              },
              onDismissed: (DismissDirection direction) {
                // Handle the dismiss action
                deleteLogItem(logItem.id!);
                setState(() {
                  logList.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Log item deleted'),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Điều chỉnh độ cong của góc bo tròn
                    side: const BorderSide(
                        color: Colors.blueGrey,
                        width: 2), // Màu và độ dày của border
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Mã số sinh viên: ${logItem.studentId}\nBiển số xe: ${logItem.numberPlate}',
                        ),
                        subtitle: Text(
                          "Thời gian check-in: ${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(logItem.timeCheckIn!))}\nThời gian checkout: ${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(logItem.timeCheckOut!))}",
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditCheckoutScreen(log: logItem)),
                          );
                        },
                      ),
                      // Image.network(
                      //   logItem.imageCheckIn.toString(),
                      //   height: 200, // Adjust the height to your desired size
                      //   fit: BoxFit.cover, // Adjust the image fit as needed
                      // ),
                      // Image.network(
                      //   logItem.imageCheckOut.toString(),
                      //   height: 200,
                      //   fit: BoxFit.cover,
                      // ),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const Divider(
            thickness: 3.0,
          ),
          itemCount: logList.length,
        ),
      ),
    );
  }
}
