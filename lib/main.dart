import 'package:flutter/material.dart';
import 'package:second_project/history.dart';
import 'package:second_project/mainhomepage.dart';
import 'package:second_project/notification.dart';
import 'package:second_project/upcoming.dart';
import 'welcome.dart';
import 'home.dart';
import 'home2.dart';

import 'login.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'branches.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'db.dart';
import 'booking.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(),
      title: 'Padel Swift',
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/main': (context) => MainPage(),
        '/main2': (context) => MainPage2(),
        '/loginPage': (context) => LoginPage(),
        '/branches': (context) => MyListView(),
        '/booking': (context) => Booking(),
        '/mainhomepage': (context) => mainhome(),
        '/upcoming': (context) => upcoming(),
        '/history': (context) => history(),
        '/notification': (context) => notification(),
      },
    );
  }
}
