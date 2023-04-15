import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'function.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db.dart';
import 'booking.dart';

int? branch_id_number;

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
        Uri.parse('http://35.223.125.10:4002/get_branches'),
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
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Container(
              width: 30,
              child: Icon(Icons.arrow_back,
                  size: 30, color: Colors.red, grade: 100),
              color: Colors.transparent,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Container(
              width: 200,
              height: 25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.transparent,
              ),
              child: Text(
                textAlign: TextAlign.center,
                "BRANCHES",
                style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              )),
          backgroundColor: Colors.green.withAlpha(200),
          flexibleSpace: ClipRect(
              child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.transparent,
            ),
          )),
          elevation: 0,
          actions: [
            Container(
              alignment: Alignment.center,
              color: Colors.transparent,
              child: IconButton(
                icon: Icon(
                  Icons.refresh,
                  size: 28,
                ),
                color: Colors.green[900],
                onPressed: _getDataFromApi,
              ),
            )
          ],
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
                      margin: EdgeInsets.all(20),
                      shadowColor: Colors.black,
                      color: Colors.white.withAlpha(200),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              "assets/images/padel_branch.jpg", // replace with your image asset path
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                        subtitle: Text(
                          _dataList[index]['branch_name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
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
