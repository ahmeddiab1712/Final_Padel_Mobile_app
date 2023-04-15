import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'welcome.dart'; // Import the main page

class MainPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black87, // set the background color here
          ),
          body: Column(
            children: [
              Card(
                elevation: 4,
                child: Container(height: 100,
                    child: Column(

                      children: [
                        Text(
                          'Duration',
                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),
                        ),
                        Row(
                          children: [
                            Container(

                            ),
                            Container(),
                            Container(),
                          ],
                        )
                      ],
                    ),
                ),
              ),
              Card(
                elevation: 4,
                child: Container(
                  width: 200,
                  height: 100,
                  child: Center(
                    child: Text(
                      'Hello, World!',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
