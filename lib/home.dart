import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'welcome.dart'; // Import the main page

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(10.0),
          child: AppBar(
            backgroundColor: Colors.black87, // set the background color here
          ),
        ),
        body: WebView(
          initialUrl: 'https://booking.padelswift.com/?pad=Focus padel',
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
