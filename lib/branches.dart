import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

int? branch_id_number;
String client_name = '';

save_branch(String branch_name, int branch_id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("branch_name", branch_name);
  prefs.setInt("branch_id", branch_id);
}

class MyListView extends StatefulWidget {
  @override
  _MyListViewState createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView> {
  List<dynamic> _dataList = [];

  @override
  void initState() {
    super.initState();
    // Call the API when the widget is first built
    _getDataFromApi();
  }

  Future<void> _getDataFromApi() async {
    // Call the API and parse the response
    final response = await http.post(
        Uri.parse('http://34.170.125.186:4002/get_branches'),
        body: json.encode({'code': 'ahmeddiab_D1NyzZTAoPbMhZ30'}));
    final jsonData = jsonDecode(response.body);

    print(jsonData);

    // Update the state with the retrieved data
    setState(() {
      _dataList = jsonData;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      client_name = prefs.getString('client_name').toString();
      final snackBar = SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Welcome Back !',
          message: 'Hello Mr $client_name',

          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.success,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    return Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          toolbarHeight: 100,
          //brightness: Brightness.dark,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Branches',
            style: TextStyle(
                fontFamily: 'Dongle',
                fontSize: 40,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
                gradient: LinearGradient(
                    colors: [Colors.indigo, Colors.black],
                    begin: Alignment.center,
                    end: Alignment.topCenter)),
          ),
        ),
        body: _dataList == null
            ? Container(
                margin: EdgeInsets.all(20), child: CircularProgressIndicator())
            : Container(
                color: Colors.white70,
                child: ListView.builder(
                  itemCount: _dataList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.only(
                          left: 40, right: 40, top: 15, bottom: 15),
                      shadowColor: Colors.blue,
                      color: Color.fromARGB(255, 82, 85, 70),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 180,
                              width: 650,
                              child: Image.asset(
                                "assets/images/dose_logo.png", // replace with your image asset path
                                height: 180,
                                fit: BoxFit.fill,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                        subtitle: Text(
                          _dataList[index]['branch_name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 25,
                              fontFamily: 'Dongle'),
                        ),
                        onTap: () async {
                          DatabaseHelper db = DatabaseHelper();
                          print(_dataList[index]['branch_name'].toString());
                          print(_dataList[index]['branch_id'].toString());
                          save_branch(
                              _dataList[index]['branch_name'].toString(),
                              _dataList[index]['branch_id']);
                          await db.updateRecord('01024527770',
                              _dataList[index]['branch_name'].toString());

                          Navigator.pushNamed(context, '/mainhomepage');
                        },
                      ),
                    );
                  },
                ),
              ));
  }
}
