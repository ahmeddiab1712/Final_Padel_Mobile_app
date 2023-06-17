import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:second_project/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'db.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'booking.dart';
import 'upcoming.dart';
import 'history.dart';
import 'notification.dart';
import 'drawer_head.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

String branch_name = '';
String mobile = '';
List<dynamic> response_message = [];

int notification_count = 0;

Future<List> get_notification_count() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  mobile = prefs.getString('mobile').toString();

  String url = 'http://35.223.125.10:4002/get_notifications';

  var requestBody = json.encode({
    'mobile': mobile,
  });
  if (mobile != '') {
    //final client = http.Client();
    int retries = 3;
    int delayInSeconds = 3;
    notification_count = 0;
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
        print("I am in get notification");
        print(response_data.data);
        notification_count = 0;
        if (response_data.statusCode == 200) {
          //print(jsonDecode(response_data.data));
          response_message = response_data.data;
          for (var i = 0; i < response_message.length; i++) {
            if (response_message[i]['read'] == false) {
              notification_count += 1;
            }
          }
          print("Noti Count" + notification_count.toString());

          return response_message.toList();
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

  return response_message.toList();
}

get_branch_name() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  branch_name = prefs.getString('branch_name').toString();
}

class mainhome extends StatefulWidget {
  mainhome({Key? key}) : super(key: key);

  @override
  _mainhomeState createState() => _mainhomeState();
}

class _mainhomeState extends State<mainhome> {
  List pages = [
    Booking(),
    upcoming(),
    history(),
    notification(),
  ];

  //int currentIndex = 0;
  int currentIndex = 0;

  void callback(int indexo) {
    setState(() {
      currentIndex = indexo;
    });
  }

  void reload_notifications() {
    get_notification();
    setState(() {
      notification_count = notification_count;
    });
  }

  void go_to_home() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  late List<Map<String, dynamic>> _dataList = [];
  Future<List<Map<String, dynamic>>> _query() async {
    DatabaseHelper db = DatabaseHelper();
    final List<Map<String, dynamic>> dataList = await db.queryAll();
    return dataList;
  }

  @override
  void initState() {
    super.initState();

    _query().then((dataList) {
      setState(() {
        _dataList = dataList;
      });
    });
    get_branch_name();
    reload_notifications();
    setState(() {
      branch_name = branch_name;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 80,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        drawer: Drawer(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  MyHeaderDrawer(),
                  Container(
                    padding: EdgeInsets.only(top: 15, right: 5, left: 5),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(25)),
                    child: Column(
                      // shows the list of menu drawer
                      children: [
                        GestureDetector(
                          child: menuItem(1, "Contact us", Icons.call),
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    child: Column(children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Our Contacts",
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[700],
                                            fontFamily: 'Dongle'),
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          String telephoneNumber =
                                              '+01024527770';
                                          String telephoneUrl =
                                              "tel:$telephoneNumber";
                                          final phone = 'tel:+01024527770';
                                          if (await canLaunch(phone)) {
                                            await launch(phone);
                                          } else {
                                            throw "Error occured trying to call that number.";
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.all(15),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.call,
                                                color: Color.fromARGB(
                                                    255, 23, 2, 6)),
                                            SizedBox(width: 20.0),
                                            Text('+201024527770',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          String email =
                                              'Mubarmijonline@gmail.com';
                                          String subject = 'Our Complain';
                                          String body = 'I wan to thank you';

                                          String emailUrl =
                                              "mailto:$email?subject=$subject&body=$body";

                                          if (await canLaunch(emailUrl)) {
                                            await launch(emailUrl);
                                          } else {
                                            throw "Error occured sending an email";
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.all(15),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.mail,
                                                color: Color.fromARGB(
                                                    255, 23, 2, 6)),
                                            SizedBox(width: 20.0),
                                            Text('mubarmijonline@gmail.com',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          const url =
                                              'https://booking.padelswift.com/booking?pad=FOCUS%20PADEL';
                                          if (await canLaunch(url)) {
                                            await launch(url);
                                          } else {
                                            throw 'Could not launch $url';
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.all(15),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.language,
                                                color: Color.fromARGB(
                                                    255, 23, 2, 6)),
                                            SizedBox(width: 20.0),
                                            Text('Booking Website',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                    ]),
                                  );
                                });
                          },
                        ),
                        /* menuItem(1, "Settings", Icons.settings), */
                        GestureDetector(
                          child: menuItem(2, "Logout", Icons.logout),
                          onTap: () => {
                            setState(() {
                              Logout();

                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                            })
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
            child: Container(
          height: 740,
          child: Stack(
            children: [pages[currentIndex]],
          ),
        )),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          selectedLabelStyle: TextStyle(fontFamily: 'Dongle', fontSize: 18),
          unselectedLabelStyle: TextStyle(fontFamily: 'Dongle', fontSize: 18),
          type: BottomNavigationBarType.shifting,
          onTap: callback,
          key: GlobalKey(),
          enableFeedback: true,
          currentIndex: currentIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey.withOpacity(0.5),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          //elevation: 0,
          items: [
            BottomNavigationBarItem(label: "Booking", icon: Icon(Icons.home)),
            BottomNavigationBarItem(
              label: "upcoming",
              icon: Icon(Icons.skip_next),
            ),
            BottomNavigationBarItem(
                label: "history", icon: Icon(Icons.history)),
            BottomNavigationBarItem(
                label: "Notifications",
                icon: Container(
                  height: 25,
                  width: 35,
                  child: Stack(
                    children: [
                      Icon(Icons.notifications_active),
                      FutureBuilder(
                          future: get_notification_count(),
                          builder: (context, snapshort) {
                            if (notification_count > 0) {
                              return Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red),
                                  child: Center(
                                      child: Text(
                                    notification_count.toString(),
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                  )),
                                ),
                              );
                            } else {
                              return Text("");
                            }
                          })
                    ],
                  ),
                )),
          ],
        ));
  }

  void Logout() async {
    DatabaseHelper db = DatabaseHelper();
    await db.update_logout_user();
  }
}

Widget menuItem(int id, String title, IconData icon) {
  return Material(
    color: Colors.grey[100],
    child: Padding(
      padding: EdgeInsets.all(15.0),
      child: Row(
        children: [
          Expanded(
            child: Icon(
              icon,
              size: 20,
              color: Colors.black,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
