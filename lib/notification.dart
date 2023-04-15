import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'function.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'app_buttons.dart';
import 'db.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? client_name;
String? client_mobile;
String? client_email;
String? branch_name;
String code = 'ahmeddiab_D1NyzZTAoPbMhZ30';
List<dynamic> response_message = [];

String cancel_res = '';

Future<List> get_notification() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  client_name = prefs.getString('client_name');
  client_mobile = prefs.getString('mobile');
  client_email = prefs.getString('email');
  branch_name = prefs.getString('branch_name');

  String url = 'http://35.223.125.10:4002/get_notifications';

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

class notification extends StatefulWidget {
  const notification({Key? key}) : super(key: key);

  @override
  _notificationState createState() => _notificationState();
}

class _notificationState extends State<notification> {
  @override
  void initState() {
    super.initState();
  }

  void reloadPage() {
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: get_notification(),
          builder: (context, snapshort) {
            if (snapshort.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshort.hasData) {
              if (response_message.length == 0) {
                return Center(
                  child: Text(
                    "No Notifications ..",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                );
              } else {
                return ListView.builder(
                    itemCount: response_message.length,
                    itemBuilder: (context, index) {
                      if (response_message[index]['type'] == 'cancel') {
                        return Column(
                          children: [
                            Card(
                              margin: EdgeInsets.all(7),
                              child: Row(
                                children: [
                                  Divider(),
                                  Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  VerticalDivider(
                                    width: 20,
                                    thickness: 20,
                                    color: Colors.black,
                                  ),
                                  Divider(),
                                  Column(
                                    children: [
                                      Divider(),
                                      Text(
                                        "Booking Canceled",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(),
                                      Text(
                                          "From :" +
                                              response_message[index]['start'] +
                                              "\nTo: " +
                                              response_message[index]['end'] +
                                              "\nCourt: " +
                                              response_message[index]
                                                  ['court_name'] +
                                              "\nBranch: " +
                                              response_message[index]
                                                  ['branch_name'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Divider(),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            Card(
                              margin: EdgeInsets.all(7),
                              child: Row(
                                children: [
                                  Divider(
                                    thickness: 2,
                                  ),
                                  Icon(Icons.check,
                                      color: Colors.green[700], size: 30),
                                  VerticalDivider(
                                    width: 20,
                                    thickness: 20,
                                    indent: 20,
                                    endIndent: 0,
                                    color: Colors.black,
                                  ),
                                  Divider(),
                                  Column(
                                    children: [
                                      Divider(),
                                      Text(
                                        "Booking Confirmed",
                                        style: TextStyle(
                                            color: Colors.green[700],
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(),
                                      Text(
                                        "From :" +
                                            response_message[index]['start'] +
                                            "\nTo: " +
                                            response_message[index]['end'] +
                                            "\nCourt: " +
                                            response_message[index]
                                                ['court_name'] +
                                            "\nBranch: " +
                                            response_message[index]
                                                ['branch_name'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    });
              }
            } else if (snapshort.hasError) {
              var error = snapshort.error;
              return Text("$error");
            }
            return const Text("Refresh Data again..");
          }),
    );
  }
}
