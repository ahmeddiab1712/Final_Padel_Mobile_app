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
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

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
      Future.delayed(Duration.zero, () {
        final snackBar = SnackBar(
          /// need to set following properties for best effect of awesome_snackbar_content
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Sorry !',
            message: 'Mobile Number is a mandatory field',

            /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else if (email == '') {
      Future.delayed(Duration.zero, () {
        final snackBar = SnackBar(
          /// need to set following properties for best effect of awesome_snackbar_content
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Sorry !',
            message: 'Email Address is a mandatory field',

            /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
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

          bool user_db_exist = await db.user_exist(
              mobile.toString(), client_email_server.toString());
          if (user_db_exist) {
            // to update all DB to False login_flag and last_login_Flag
            // assign the login flag to the current login user to make it easier auto-login
            await db.updateRecord_login(
                mobile.toString(), client_name_server, client_email_server);
          } else {
            // turn all login_flag to false
            // insert the new record and make the user the auto-login

            await db.insert({
              'client_mobile': mobile.toString(),
              'client_email': client_email_server.toString(),
              'client_name': client_mobile_server.toString(),
              'log_in': 1,
              'last_login': 1
            });
          }

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
          Future.delayed(Duration.zero, () {
            final snackBar = SnackBar(
              /// need to set following properties for best effect of awesome_snackbar_content
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Sorry !',
                message: 'Mobile not matched with the Email',

                /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                contentType: ContentType.failure,
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          });
        } else if (state == 'wrong_email') {
          Future.delayed(Duration.zero, () {
            final snackBar = SnackBar(
              /// need to set following properties for best effect of awesome_snackbar_content
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Sorry !',
                message: 'Email Address not matched with  Mobile',

                /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                contentType: ContentType.failure,
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          });
        } else if (state == 'banned') {
          Future.delayed(Duration.zero, () {
            final snackBar = SnackBar(
              /// need to set following properties for best effect of awesome_snackbar_content
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Sorry !',
                message: 'This Account is banned ..',

                /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                contentType: ContentType.failure,
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          });
        }

        //SharedPreferences prefs = await SharedPreferences.getInstance();
        //prefs.setString('client_name', client_name);
        //prefs.setString('client_email', client_email);
      } else {
        Future.delayed(Duration.zero, () {
          final snackBar = SnackBar(
            /// need to set following properties for best effect of awesome_snackbar_content
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'System Error !',
              message: 'Kindly Refresh and login again ..',

              /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
              contentType: ContentType.failure,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
        //print('Error: ${response.reasonPhrase}');
      }
    }
  } catch (e) {
    print(e);
    Future.delayed(Duration.zero, () {
      final snackBar = SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'System is down !',
          message: 'System will be up in minutes ..',

          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
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
        Future.delayed(Duration.zero, () {
          final snackBar = SnackBar(
            /// need to set following properties for best effect of awesome_snackbar_content
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'System Went Wrong !',
              message: 'Kindly refesh and login again',

              /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
              contentType: ContentType.failure,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      }

      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //prefs.setString('client_name', client_name);
      //prefs.setString('client_email', client_email);
    } else {
      showErrorDialog(context, "");
      //print('Error: ${response.reasonPhrase}');
    }
  } catch (error) {
    Future.delayed(Duration.zero, () {
      final snackBar = SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'System is down !',
          message: 'System will be up in minutes ..',

          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }
}
