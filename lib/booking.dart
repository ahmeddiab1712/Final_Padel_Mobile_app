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
import 'package:rflutter_alert/rflutter_alert.dart';
import 'login.dart';
import 'dart:io';

String? client_name;
String? client_mobile;
String? client_email;
String? branch_name;

String branchname_str = '';

get_branch_name() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  branchname_str = prefs.getString('branch_name').toString();
}

Future<List> get_appointment_times() async {
  duration_value = duration_id;
  court_type_value = court_type_id;
  new_booking_date = new_booking_date;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  client_name = prefs.getString('client_name');
  client_mobile = prefs.getString('mobile');
  client_email = prefs.getString('email');
  branch_name = prefs.getString('branch_name');

  print(client_mobile);

  print(
      "duration value is $duration_value || court_type value is $court_type_value || booking_date is $new_booking_date ");

  String url = 'http://35.223.125.10:4002/get_appointment_time';

  var requestBody = json.encode({
    'booking_date': new_booking_date,
    'duration': duration_value,
    'court_type': court_type_value,
    'branch_name': branch_name
  });
  if (duration_value != '' &&
      court_type_value != '' &&
      new_booking_date != '' &&
      branch_name != '') {
    //final client = http.Client();
    int retries = 3;
    int delayInSeconds = 3;

    while (retries > 0) {
      try {
        final Response response_data = await Dio().post(url, data: requestBody);
/*           request.headers['Connection'] = 'Keep-Alive';
          request.headers['Keep-Alive'] = 'timeout=20, max=1000';
          request.headers['Content-Type'] = 'application/json';
          request.body = requestBody; */
        if (response_data.statusCode == 200) {
          var response_message = jsonDecode((response_data.data));
          print(response_message);
          start_time.clear();
          end_time.clear();
          court_list.clear();
          time_id.clear();
          var counter = 0;
          if (response_message['data'].length <= 0) {
            throw http.ClientException(
                '\n\nSorry No Available Time ..\n\nKindly Choose another date or another branch');
          } else {
            for (var elements in response_message['data']) {
              counter++;
              start_time.add(elements['start']);
              end_time.add(elements['end']);
              time_id.add(elements['time_id']);
              court_list.add(elements['courts']);
            }
            print(court_list);

            print(court_list[0][0].toString());

            return start_time;
          }
        }
        //Map<String, dynamic> response_message = jsonDecode(response.body);
      } on DioError catch (dioError) {
        print('Error occurred: $dioError');
      }
      retries--;
      if (retries > 0) {
        print('Retrying after $delayInSeconds seconds');
        await Future.delayed(Duration(seconds: delayInSeconds));
        delayInSeconds *= 1;
      }
    }

    //throw http.ClientException('Failed to send request after 3 retrials');
  } else {
    throw http.ClientException(
        'System Error .. Kindly Logout & Login Again ..');
  }

  return start_time;
}

String duration_id = '60';
String court_type_id = 'Double';
String duration_value = '';
String court_type_value = '';
String dropdownvalue = '';

final List<String> start_time = [];
final List<String> end_time = [];
final List<dynamic> court_list = [];
final List<dynamic> time_id = [];
List<dynamic> courts = [];
DateTime selected_date = DateTime.now();

// Format the date
String new_booking_date = DateFormat('yyyy-MM-dd').format(selected_date);

class Booking extends StatefulWidget {
  const Booking({Key? key}) : super(key: key);

  @override
  _BookingState createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  void reloadPage() {
    setState(() {});
  }

  DatePickerController _controller = DatePickerController();
  bool isloading = false;
  var count = 0;
  var dio = Dio();

  DateTime _selectedValue = DateTime.now();
  List<dynamic> duration = [];

  List<dynamic> court_type = [];

  late List<Map<String, dynamic>> _dataList = [];

  Future<List<Map<String, dynamic>>> _query() async {
    DatabaseHelper db = DatabaseHelper();
    final List<Map<String, dynamic>> dataList = await db.queryAll();
    return dataList;
  }

  void initState() {
    super.initState();

    this.duration.add({"duration_id": 60, "duration": "60 Min"});
    this.duration.add({"duration_id": 90, "duration": "90 Min"});
    this.duration.add({"duration_id": 120, "duration": "120 Min"});

    this.court_type.add({"id": "Double", "label": "Double"});
    this.court_type.add({"id": "Single", "label": "Single"});

    //get_appointment_times();
  }

  @override
  Widget build(BuildContext context) {
    get_branch_name();
    print("The BRANCHHH" + branchname_str);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[200],
        body: SafeArea(
          child: Container(
            child: Column(
              children: [
                FutureBuilder(
                  future: get_branch_name(),
                  builder: (context, snapshot) {
                    return Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.only(left: 30, right: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        Text(
                          "Branch",
                          style: TextStyle(
                              fontSize: 40,
                              fontFamily: 'Dongle',
                              color: Color.fromARGB(255, 222, 170, 15)),
                        ),
                        Text("   "),
                        Text("   "),
                        Text("   "),
                        Text("   "),
                        Text("   "),
                        Text(
                          branchname_str,
                          style: TextStyle(
                              fontSize: 40,
                              fontFamily: 'Dongle',
                              color: Color.fromARGB(255, 4, 53, 90)),
                        )
                      ]),
                    );
                  },
                ),
                Card(
                  margin: EdgeInsets.all(3),
                  shadowColor: Colors.black,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: FormHelper.dropDownWidgetWithLabel(
                      context,
                      "Duration",
                      "Select Duration",
                      duration_id,
                      this.duration,
                      (onChangedVal) {
                        duration_id = onChangedVal;
                        setState(() {
                          duration_value = onChangedVal;
                        });
                        print("The value is $duration_value");
                      },
                      (onValidateVal) {
                        if (onValidateVal == null) {
                          return "Please select Duration";
                        }
                        return null;
                      },
                      borderColor: Theme.of(context).primaryColorDark,
                      borderFocusColor: Theme.of(context).primaryColorDark,
                      borderRadius: 15,
                      optionValue: "duration_id",
                      optionLabel: "duration",
                      labelFontSize: 15,
                      labelBold: true,
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.all(3),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: FormHelper.dropDownWidgetWithLabel(
                      context,
                      'Court Type',
                      "Court Type",
                      court_type_id,
                      this.court_type,
                      (onChangedVal) {
                        court_type_id = onChangedVal;
                        setState(() {
                          court_type_id = onChangedVal;
                        });
                        print("The value is $court_type_id");
                      },
                      (onValidateVal) {},
                      borderColor: Theme.of(context).primaryColor,
                      borderFocusColor: Theme.of(context).primaryColor,
                      borderRadius: 15,
                      optionValue: "id",
                      optionLabel: "label",
                      labelFontSize: 15,
                      labelBold: true,
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.all(3),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        DatePicker(
                          DateTime.now(),
                          initialSelectedDate: DateTime.now(),
                          selectionColor: Colors.black,
                          selectedTextColor: Colors.white,
                          onDateChange: (date) {
                            // New date selected
                            setState(() {
                              new_booking_date =
                                  DateFormat('yyyy-MM-dd').format(date);
                              print("The Selected Date is $new_booking_date");
                              DateTime nextDate = date.add(Duration(days: 1));
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                FutureBuilder(
                    future: get_appointment_times(),
                    builder: (context, snapshort) {
                      if (snapshort.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshort.hasData) {
                        return Container(
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                              child: Column(
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Available Slots',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.green[500]),
                              ),
                              SizedBox(
                                height: 200,
                                child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2),
                                    itemCount: start_time.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) =>
                                        GestureDetector(
                                          onTap: () => {
                                            //print(start_time[index])
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                List<dynamic> courts = [];
                                                String court_id =
                                                    court_list[index][0];

                                                for (int i = 0;
                                                    i <
                                                        court_list[index]
                                                            .length;
                                                    i++) {
                                                  courts.add({
                                                    "id": (i + 1).toString(),
                                                    "court_name":
                                                        court_list[index][i]
                                                  });
                                                }

                                                print(court_id);
                                                print(courts);
                                                int dd = int.parse(duration_id);

                                                String start_datetime_final =
                                                    new_booking_date +
                                                        " " +
                                                        start_time[index];
                                                DateFormat date_start_format =
                                                    DateFormat(
                                                        'yyyy-MM-dd hh:mm a');

                                                DateTime dato =
                                                    date_start_format.parse(
                                                        start_datetime_final);

                                                if (time_id[index] >= 41) {
                                                  dato = dato
                                                      .add(Duration(days: 1));
                                                }
                                                DateTime newDateTime = dato
                                                    .add(Duration(minutes: dd));
                                                String end_datetime = DateFormat(
                                                        'E yyyy-MM-dd hh:mm a')
                                                    .format(newDateTime);

                                                String start_datetime = DateFormat(
                                                        'E yyyy-MM-dd hh:mm a')
                                                    .format(dato);
                                                return Card(
                                                  child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Title(
                                                          child: Text(
                                                              "You Picked the below",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          color: Colors.red,
                                                        ),
                                                        Divider(
                                                          thickness: 2,
                                                        ),
                                                        DataTable(columns: [
                                                          DataColumn(
                                                            label: (Text(
                                                                'Start Time',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        14))),
                                                          ),
                                                          DataColumn(
                                                            label: (Text(
                                                                start_datetime,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .green,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        14))),
                                                          ),
                                                        ], rows: [
                                                          DataRow(cells: [
                                                            DataCell(Text(
                                                                'End Time',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        14))),
                                                            DataCell(Text(
                                                                end_datetime,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .green,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        14))),
                                                          ]),
                                                          DataRow(cells: [
                                                            DataCell(Text(
                                                                'Duration',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        14))),
                                                            DataCell(Text(
                                                                duration_id +
                                                                    " Minutes",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .green,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        14))),
                                                          ]),
                                                        ]),
                                                        Divider(
                                                          thickness: 2,
                                                        ),
                                                        Card(
                                                            child: Column(
                                                          children: [
                                                            Divider(),
                                                            Text(
                                                              "Choose Court ",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .amber,
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Text(""),
                                                            SizedBox(
                                                              height: 50,
                                                              child: FormHelper.dropDownWidget(
                                                                  context,
                                                                  "choose Court",
                                                                  court_id
                                                                      .toString(),
                                                                  courts
                                                                      .toList(),
                                                                  (onChangedVal) {
                                                                court_id =
                                                                    onChangedVal;
                                                                print(
                                                                    "$onChangedVal");
                                                                setState(() {
                                                                  court_id =
                                                                      onChangedVal;
                                                                });
                                                              }, (onValidateVal) {
                                                                if (onValidateVal ==
                                                                    null) {
                                                                  return "Please Select Court";
                                                                }
                                                              },
                                                                  borderColor: Theme.of(
                                                                          context)
                                                                      .primaryColorDark,
                                                                  borderFocusColor:
                                                                      Theme.of(
                                                                              context)
                                                                          .primaryColorDark,
                                                                  borderRadius:
                                                                      10,
                                                                  optionLabel:
                                                                      'court_name',
                                                                  optionValue:
                                                                      'court_name'),
                                                            ),
                                                            Divider(
                                                              thickness: 0,
                                                            ),
                                                            Divider(
                                                              thickness: 0,
                                                            ),
                                                            Divider(
                                                              thickness: 0,
                                                            ),
                                                            SlideAction(
                                                              child: Text(
                                                                  "Slide To Confirm"),
                                                              height: 60,
                                                              sliderButtonIconSize:
                                                                  20,
                                                              onSubmit: () => {
                                                                setState(() {
                                                                  isloading =
                                                                      true;
                                                                }),
                                                                Navigator.pop(
                                                                    context),
                                                                add_appointment(
                                                                    court_id
                                                                        .toString(),
                                                                    new_booking_date,
                                                                    duration_id
                                                                        .toString(),
                                                                    start_time[
                                                                        index],
                                                                    end_time[
                                                                        index]),
                                                              },
                                                            )
                                                          ],
                                                        ))
                                                      ]),
                                                );
                                              },
                                            )
                                          },
                                          child: Container(
                                            height: 50,
                                            width: 50,
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color: Colors.black,
                                                    width: 1.0)),
                                            margin: EdgeInsets.all(10),
                                            child: Center(
                                                child: Text(
                                              start_time[index],
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                          ),
                                        )),
                              )
                            ],
                          )),
                        );
                      } else if (snapshort.hasError) {
                        var error = snapshort.error;
                        return Column(children: [
                          Text("$error"),
                          GestureDetector(
                            child: Icon(Icons.refresh),
                            onTap: () => {get_appointment_times()},
                          )
                        ]);
                      }
                      return const Text("Refresh Data again..");
                    }),
              ],
            ),
          ),
        ));
  }

  void add_appointment(String court_name, String selected_date, String Duration,
      String time_start, String time_end) async {
    showErrorDialog(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    client_mobile = prefs.getString('mobile');
    branch_name = prefs.getString('branch_name');
    String url1 = 'http://35.223.125.10:4002/add_time_slot?add_time_slot';

    var requestBody = json.encode({
      'court_name': court_name,
      'client_mobile': client_mobile,
      'duration': duration_value,
      'date': selected_date,
      'branch_name': branch_name,
      'time_start': time_start,
      'time_end': time_end
    });

    if (court_name == '' ||
        client_mobile == '' ||
        duration_value == '' ||
        branch_name == '' ||
        time_start == '' ||
        time_end == '') {
      Alert(
        context: context,
        type: AlertType.error,
        title: "Your account is logged out",
        desc: "Kindly click on logout button",
        buttons: [
          DialogButton(
            color: Colors.blue,
            child: Text(
              "logout",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () async {
              Navigator.pop(context);

              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => LoginPage()));
            },
            width: 120,
          ),
        ],
      ).show();
    } else {
      try {
        final Response response_data =
            await Dio().post(url1, data: requestBody);

        if (response_data.statusCode == 200) {
          if (response_data.data['state'] == 'success') {
            reloadPage();
            setState(() {
              isloading = false;
            });
            Navigator.pop(context);
            Alert(
              context: context,
              type: AlertType.success,
              title: "Booking Done Successfully ..",
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
          } else if (response_data.data['state'] == 'banned') {
            Navigator.pop(context);
            Alert(
              context: context,
              type: AlertType.error,
              title: "Sorry, You are banned from booking",
              desc:
                  "For more information,\nKindly contact Padel's Administrator",
              buttons: [
                DialogButton(
                  color: Colors.blue,
                  child: Text(
                    "Ok",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () => {
                    Navigator.pop(context),
                  },
                  width: 120,
                ),
              ],
            ).show();
          } else if (response_data.data['data_missing'] == '') {
            Navigator.pop(context);
            Alert(
              context: context,
              type: AlertType.error,
              title: "Sorry, System Error",
              desc: "Kindly Logout and Login again ..",
              buttons: [
                DialogButton(
                  color: Colors.blue,
                  child: Text(
                    "Ok",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () => {
                    Navigator.pop(context),
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginPage()))
                  },
                  width: 120,
                ),
              ],
            ).show();
          } else if (response_data.data['state'] == 'time_passed') {
            reloadPage();
            setState(() {
              isloading = false;
            });
            Navigator.pop(context);
            Alert(
              context: context,
              type: AlertType.error,
              title: "Sorry,This time slot is\nno longer available ..",
              desc: "Kindly choose another slot",
              buttons: [
                DialogButton(
                  color: Colors.blue,
                  child: Text(
                    "Ok",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () => {
                    Navigator.pop(context),
                  },
                  width: 120,
                ),
              ],
            ).show();
          } else if (response_data.data['state'] == 'duplicate') {
            reloadPage();
            setState(() {
              isloading = false;
            });
            Navigator.pop(context);
            Alert(
              context: context,
              type: AlertType.error,
              title: "Sorry, This slot is now busy ..",
              desc: "Kindly choose another slot",
              buttons: [
                DialogButton(
                  color: Colors.blue,
                  child: Text(
                    "Ok",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () => {
                    Navigator.pop(context),
                  },
                  width: 120,
                ),
              ],
            ).show();
          } else {
            reloadPage();
            setState(() {
              isloading = false;
            });
            Navigator.pop(context);
            Alert(
              context: context,
              type: AlertType.error,
              title: "System Error",
              desc: "Kindly Refersh .. ",
              buttons: [
                DialogButton(
                  color: Colors.blue,
                  child: Text(
                    "Ok",
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
        }
      } on DioError catch (dioError) {
        print('Error occurred: $dioError');
      }
    }
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
