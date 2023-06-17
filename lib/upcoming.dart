import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

String? client_name;
String? client_mobile;
String? client_email;
String? branch_name;
String code = 'ahmeddiab_D1NyzZTAoPbMhZ30';
List<dynamic> response_message = [];

String cancel_res = '';

Future<List> get_upcoming_booking() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  client_name = prefs.getString('client_name');
  client_mobile = prefs.getString('mobile');
  client_email = prefs.getString('email');
  branch_name = prefs.getString('branch_name');

  String url = 'http://35.223.125.10:4002/get_upcoming_booking';

  print(response_message);

  var requestBody = json.encode({
    'mobile': client_mobile,
  });
  if (client_mobile != '') {
    //final client = http.Client();
    int retries = 3;
    int delayInSeconds = 3;

    while (retries > 0) {
      print("inside loop");
      try {
        print("inside try");
        final Response response_data = await Dio().post(url, data: requestBody);

/*           request.headers['Connection'] = 'Keep-Alive';
          request.headers['Keep-Alive'] = 'timeout=20, max=1000';
          request.headers['Content-Type'] = 'application/json';
          request.body = requestBody; */
        //print(response_data.runtimeType);
        print(response_data.data);
        if (response_data.statusCode == 200) {
          //print(jsonDecode(response_data.data));
          response_message = response_data.data;
          ;
          print(response_message);

          var counter = 0;

          return response_message;
        }
        //Map<String, dynamic> response_message = jsonDecode(response.body);
      } catch (e) {
        print('Error occurred: $e');
      }
      retries--;
      if (retries > 0) {
        print('Retrying after $delayInSeconds seconds');
        await Future.delayed(Duration(seconds: delayInSeconds));
        delayInSeconds *= 1;
      }
    }

    //throw http.ClientException('Failed to send request after 3 retrials');
  }

  return response_message;
}

class upcoming extends StatefulWidget {
  const upcoming({Key? key}) : super(key: key);

  @override
  _upcomingState createState() => _upcomingState();
}

class _upcomingState extends State<upcoming> {
  void reloadPage() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  String cancel_status = '';
  void cancel_booking(int calc_id, String court_name, String time_start,
      String time_end, String duration) async {
    void showErrorDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Center(
              child: CircularProgressIndicator(),
            ),
            backgroundColor: Colors.transparent,
          );
        },
      );
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    client_name = prefs.getString('client_name');
    client_mobile = prefs.getString('mobile');
    client_email = prefs.getString('email');
    branch_name = prefs.getString('branch_name');

    String url = 'http://35.223.125.10:4002/cancel_booking?cancel_booking';

    var requestBody = json.encode({
      'client_mobile': client_mobile,
      'calc_id': calc_id,
      'branch_name': branch_name,
      'court_name': court_name,
      'time_start': time_start,
      'time_end': time_end,
      'client_name': client_name,
      'client_email': client_email,
      'duration': duration
    });
    if (client_mobile != '') {
      //final client = http.Client();
      int retries = 3;
      int delayInSeconds = 3;

      while (retries > 0) {
        print("inside loop");
        try {
          print("inside try");
          final Response response_data =
              await Dio().post(url, data: requestBody);

/*           request.headers['Connection'] = 'Keep-Alive';
          request.headers['Keep-Alive'] = 'timeout=20, max=1000';
          request.headers['Content-Type'] = 'application/json';
          request.body = requestBody; */
          //print(response_data.runtimeType);
          print(response_data.data);
          if (response_data.statusCode == 200) {
            //print(jsonDecode(response_data.data));
            //cancel_response = response_data.data;
            print(response_data.data);
            //print(cancel_response);
            if (response_data.data['state'] == 'success') {
              cancel_status = 'success';

              Alert(
                context: context,
                type: AlertType.success,
                title: "Booking Canceled Succesfully",
                desc: "",
                buttons: [
                  DialogButton(
                    color: Colors.greenAccent,
                    child: Text(
                      "close",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () => {Navigator.pop(context)},
                    width: 120,
                  ),
                ],
              ).show();
              reloadPage();
            }

            var counter = 0;
            if (response_message.length <= 0) {
              throw http.ClientException('\n\nSorry System Error');
            }
          }
          //Map<String, dynamic> response_message = jsonDecode(response.body);
        } catch (e) {
          print('Error occurred: $e');
        }
        retries--;
        if (retries > 0) {
          print('Retrying after $delayInSeconds seconds');
          await Future.delayed(Duration(seconds: delayInSeconds));
          delayInSeconds *= 1;
        }
      }

      //throw http.ClientException('Failed to send request after 3 retrials');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        //body: Text("UpComing is comming soon.."),
        backgroundColor: Colors.grey[600],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            "Upcoming Bookings",
            textAlign: TextAlign.right,
          ),
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: FutureBuilder(
            future: get_upcoming_booking(),
            builder: (context, snapshort) {
              if (snapshort.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshort.hasData) {
                if (response_message.length == 0) {
                  return Container(
                      margin: EdgeInsets.all(10),
                      color: Colors.white,
                      height: 1000,
                      width: 500,
                      child: Center(
                        child: Text(
                          "No Upcoming Bookings ..",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                      ));
                } else {
                  return Container(
                      child: ListView.builder(
                          itemCount: response_message.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: EdgeInsets.all(8),
                              shadowColor: Colors.black,
                              child: ListTile(
                                subtitle: Column(children: [
                                  DataTable(columns: [
                                    DataColumn(
                                      label: (Text('Start Time',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14))),
                                    ),
                                    DataColumn(
                                      label: (Text(
                                          response_message[index]['start'],
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14))),
                                    ),
                                  ], rows: [
                                    DataRow(cells: [
                                      DataCell(Text('End Time',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14))),
                                      DataCell(Text(
                                          response_message[index]['end'],
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14))),
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('Duration',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14))),
                                      DataCell(Text(
                                          response_message[index]
                                                      ['total_minutes']
                                                  .toString() +
                                              " Minutes",
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14))),
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('Branch',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14))),
                                      DataCell(Text(
                                          response_message[index]['branch_name']
                                              .toString(),
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14))),
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('Court',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14))),
                                      DataCell(Text(
                                          response_message[index]['room']
                                              .toString(),
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14))),
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('Amount',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14))),
                                      DataCell(Text(
                                          response_message[index]['amount']
                                                  .toString() +
                                              " L.E",
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14))),
                                    ]),
                                  ]),
                                  Divider(),
                                  SizedBox(
                                    width: 100,
                                    height: 35,
                                    child: ElevatedButton(
                                        onPressed: () => {
                                              Alert(
                                                context: context,
                                                type: AlertType.error,
                                                title:
                                                    "Are you sure to cancel ?",
                                                desc: "",
                                                buttons: [
                                                  DialogButton(
                                                    color: Colors.blue,
                                                    child: Text(
                                                      "Yes,Cancel",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20),
                                                    ),
                                                    onPressed: () => {
                                                      cancel_booking(
                                                          response_message[
                                                              index]['id'],
                                                          response_message[
                                                              index]['room'],
                                                          response_message[
                                                              index]['start'],
                                                          response_message[
                                                              index]['end'],
                                                          response_message[
                                                                      index][
                                                                  'total_minutes']
                                                              .toString()),
                                                      Navigator.pop(context),
                                                    },
                                                    width: 120,
                                                  ),
                                                  DialogButton(
                                                    color: Colors.red,
                                                    child: Text(
                                                      "Close",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20),
                                                    ),
                                                    onPressed: () => {
                                                      Navigator.pop(context)
                                                    },
                                                    width: 120,
                                                  )
                                                ],
                                              ).show(),
                                            },
                                        child: Text("Cancel"),
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.red)),
                                  ),
                                ]),
                              ),
                            );
                            //end of else
                          }));
                }
              } else if (snapshort.hasError) {
                var error = snapshort.error;
                return Text("$error");
              }
              return const Text("Refresh Data again..");
            }));
  }
}

void showErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Center(
          child: CircularProgressIndicator(),
        ),
        backgroundColor: Colors.transparent,
      );
    },
  );
}
