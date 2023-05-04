import 'package:flutter/material.dart';
import 'package:second_project/function.dart';
import 'package:shared_preferences/shared_preferences.dart';

String clientname = '';
String clientmobile = '';
String clientemail = '';

class MyHeaderDrawer extends StatefulWidget {
  @override
  _MyHeaderDrawerState createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  void initState() {
    super.initState();
    get_client_info();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      padding: EdgeInsets.only(top: 30.0),
      decoration: BoxDecoration(
          color: Colors.indigo,
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(25),
              bottomLeft: Radius.circular(25))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10),
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/padel_tennis_header.jpg'),
              ),
            ),
          ),
          Text(
            clientname,
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'Dongle'),
          ),
          Text(clientmobile,
              style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Dongle')),
          Text(
            clientemail,
            style: TextStyle(
                color: Colors.grey[200],
                fontSize: 25,
                fontWeight: FontWeight.bold,
                fontFamily: 'Dongle'),
          ),
        ],
      ),
    );
  }

  get_client_info() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      clientname = prefs.getString('client_name') ?? "Padel Member";
      clientmobile = prefs.getString('mobile') ?? "";
      clientemail = prefs.getString('email') ?? "";
    });
  }
}
