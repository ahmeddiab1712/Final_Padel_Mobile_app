import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:second_project/login.dart';
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
import 'booking.dart';
import 'upcoming.dart';
import 'history.dart';
import 'notification.dart';
import 'drawer_head.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

String branch_name = '';

get_branch_name() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  branch_name = prefs.getString('branch_name').toString();
}

class mainhome extends StatefulWidget {
  const mainhome({Key? key}) : super(key: key);

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
  int currentIndex = 0;
  void onTap(int index) {
    setState(() {
      currentIndex = index;
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
    setState(() {
      branch_name = branch_name;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          flexibleSpace: ClipRect(
              child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.transparent,
            ),
          )),
          backgroundColor: Colors.green[700],
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
                        menuItem(1, "Settings", Icons.settings),
                        GestureDetector(
                          child: menuItem(2, "Logout", Icons.logout),
                          onTap: () => {
                            setState(() {
                              print("i am here");
                              Logout();
                              print("i am there");
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
        body: pages[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.shifting,
          onTap: onTap,
          currentIndex: currentIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey.withOpacity(0.5),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          items: [
            BottomNavigationBarItem(label: "Booking", icon: Icon(Icons.home)),
            BottomNavigationBarItem(
                label: "upcoming", icon: Icon(Icons.skip_next)),
            BottomNavigationBarItem(
                label: "history", icon: Icon(Icons.history)),
            BottomNavigationBarItem(
                label: "Notifications", icon: Icon(Icons.notifications)),
          ],
        ));
  }

  void Logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('client_name', '');
    prefs.setString('mobile', '');
    prefs.setString('email', '');
    prefs.setString('branch_name', '');

    print("i am here");
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
