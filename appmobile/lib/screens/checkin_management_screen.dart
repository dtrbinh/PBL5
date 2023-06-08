import 'dart:convert';

import 'package:appmobile/models/checkin.dart';
import 'package:appmobile/screens/edit_checkin_screen.dart';
import 'package:appmobile/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

class CheckInManagement extends StatefulWidget {
  const CheckInManagement({super.key});

  @override
  State<CheckInManagement> createState() => _CheckInManagementState();
}

class _CheckInManagementState extends State<CheckInManagement> {
  List<CheckIn> checkinList = [];
  var isLoaded = false;

  void _reloadData() {
    // Implement the logic to reload the data here
    // For example, you can call the API again to fetch the latest student data
    getAllCheckIns();
  }

  bool isReloading = false;
  Future<void> reloadData() async {
    // Add your data reloading logic here
    // For example, call your API to fetch updated data
    getAllCheckIns();

    // Simulating a delay of 2 seconds
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      // Update your data and set isReloading to false
      // For example, update studentList with the new data
      isReloading = false;
    });
  }

  Future<void> getAllCheckIns() async {
    var url = Uri.http(Constant.server, '/check-ins');
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
        checkinList = checkIns.reversed.toList();
        debugPrint("$checkIns");
      });
    } else {
      debugPrint(
          'Failed to fetch check-ins. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteCheckin(String checkinId) async {
    var url = Uri.http(Constant.server, '/check-ins/$checkinId');

    var response = await http.delete(url);

    if (response.statusCode == 200) {
      // Student deleted successfully
      debugPrint('Student deleted');
    } else {
      debugPrint(
          'Failed to delete student. Status code: ${response.statusCode}');
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
        backgroundColor: Colors.blueGrey,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            isLoaded = false;
          });
          await reloadData();
        },
        child: ListView.separated(
          physics:
              const AlwaysScrollableScrollPhysics(), // Allow scrolling even when content is not overscrolling
          itemBuilder: (context, index) {
            final checkinItem = checkinList[index];
            return Dismissible(
              key: Key(checkinItem.id!),
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
              onDismissed: (direction) {
                // Handle the delete action here
                deleteCheckin(checkinItem.id!);
                setState(() {
                  checkinList.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xoá checkin'),
                  ),
                );
              },
              confirmDismiss: (direction) async {
                // Show confirmation dialog
                bool confirm = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Xác nhận xoá'),
                      content: Text('Bạn có chắc chắn muốn xoá checkin này?'),
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
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditCheckinScreen(checkIn: checkinItem),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                            'Mã số sinh viên: ${checkinItem.studentId}\nBiển số xe: ${checkinItem.numberPlate}',
                          ),
                          subtitle: Text(
                            "Thời gian check-in: ${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(checkinItem.timeCheckIn!))}",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const Divider(
            thickness: 3.0,
          ),
          itemCount: checkinList.length,
        ),
      ),
    );
  }
}
