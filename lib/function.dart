import 'login.dart';
import 'package:flutter/material.dart';
import 'function.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'branches.dart';
import 'dart:io';
import 'db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

final String url = 'http://35.223.125.10:4002/login';

save_session(String mobile, String email, String client_name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print("$mobile || $email || $client_name ");
  prefs.setString("mobile", mobile);
  prefs.setString("email", email);
  prefs.setString("client_name", client_name);
}

String client_name = "";
String client_email = "";

var client_name_input = TextEditingController();

Future<void> sendDataToServer(
    BuildContext context, String mobile, String email) async {
  try {
    if (mobile == '') {
      showErrorDialog(context, "Mobile Number is missing");
    } else if (email == '') {
      showErrorDialog(context, "Email Address is missing");
    } else {
      final response = await http.post(Uri.parse(url),
          body: json.encode({'client_mobile': mobile, 'client_email': email}));
      //EasyLoading.show(status: 'Loading...');
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('Data sent successfully!');

        Map<String, dynamic> response_message = jsonDecode(response.body);

        print(response_message);

        var state = response_message['state'];
        //EasyLoading.dismiss();
        if (state == 'success') {
          String client_email_server = response_message['client_email'];
          String client_mobile_server = response_message['client_mobile'];
          String client_name_server = response_message['client_name'];
          DatabaseHelper db = DatabaseHelper();
          await db.insert({'client_mobile': mobile.toString()});
          save_session(
              client_mobile_server, client_email_server, client_name_server);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyListView(),
            ),
          );
        } else if (state == 'register') {
          print("Need to register");
          client_name_input.text = '';
          showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 1200,
                  color: Colors.grey[300],
                  child: Column(children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Looks Like a New Member',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700]),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("What is your name ?",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700])),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[100],
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12)),
                          child: TextField(
                            controller: client_name_input,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Your Name"),
                          ),
                        )),
                    SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () {
                          print(mobile);
                          print(email);
                          print(client_name_input.text);
                          if (client_name_input.text == '') {
                            showErrorDialog(context, "Your Name is missing");
                          } else {
                            sign_up(context, mobile, email,
                                client_name_input.text.toString());
                          }
                        },
                        child: Text("Sign up"))
                  ]),
                );
              });
        } else if (state == 'wrong_mobile') {
          Alert(
            context: context,
            type: AlertType.error,
            title: "Mobile Number not matched with the email",
            desc: "",
            buttons: [
              DialogButton(
                color: Colors.blue,
                child: Text(
                  "close",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => {
                  Navigator.pop(context),
                },
                width: 120,
              ),
            ],
          ).show();
        } else if (state == 'wrong_email') {
          Alert(
            context: context,
            type: AlertType.error,
            title: "Email not matched with the Mobile Number",
            desc: "",
            buttons: [
              DialogButton(
                color: Colors.blue,
                child: Text(
                  "close",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => {
                  Navigator.pop(context),
                },
                width: 120,
              ),
            ],
          ).show();
        } else if (state == 'banned') {
          Alert(
            context: context,
            type: AlertType.error,
            title: "You are banned",
            desc: "For more information,\nKindly contact Padel's Administrator",
            buttons: [
              DialogButton(
                color: Colors.blue,
                child: Text(
                  "close",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => {
                  Navigator.pop(context),
                },
                width: 120,
              ),
            ],
          ).show();
        }

        //SharedPreferences prefs = await SharedPreferences.getInstance();
        //prefs.setString('client_name', client_name);
        //prefs.setString('client_email', client_email);
      } else {
        showErrorDialog(context, "");
        //print('Error: ${response.reasonPhrase}');
      }
    }
  } catch (error) {
    print(error);
    showErrorDialog(context, "System Error");
  }
}

Future<void> sign_up(BuildContext context, String mobile, String email,
    String client_name) async {
  try {
    String sign_up_url = "http://35.223.125.10:4002/sign_up";
    final response = await http.post(Uri.parse(sign_up_url),
        body: json.encode({
          'client_mobile': mobile,
          'client_email': email,
          'client_name': client_name
        }));
    //EasyLoading.show(status: 'Loading...');

    print(response.statusCode);
    if (response.statusCode == 200) {
      print('Data sent successfully!');

      Map<String, dynamic> response_message = jsonDecode(response.body);

      print(response_message);

      var state = response_message['feedback'];
      //EasyLoading.dismiss();
      if (state == 'success') {
        String client_email_server = email;
        String client_mobile_server = mobile;
        String client_name_server = client_name;
        DatabaseHelper db = DatabaseHelper();
        await db.insert({'client_mobile': mobile.toString()});
        save_session(
            client_mobile_server, client_email_server, client_name_server);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyListView(),
          ),
        );
      } else {
        showErrorDialog(context, "Something went wrong .. ");
      }

      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //prefs.setString('client_name', client_name);
      //prefs.setString('client_email', client_email);
    } else {
      showErrorDialog(context, "");
      //print('Error: ${response.reasonPhrase}');
    }
  } catch (error) {
    print(error);
    showErrorDialog(context, "System Error");
  }
}
