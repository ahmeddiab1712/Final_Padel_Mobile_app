import 'package:flutter/material.dart';

class Moamen_test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Moamen Hassan"),
        centerTitle: true,
        leading: BackButton(
          color: const Color.fromARGB(255, 187, 9, 9),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Text("CONTAINERSSSSSSSS"),
            Row(
              children: [Text("Ahmed Diab"), Text("Khaled Attiaaa Fawazyy")],
            ),
            Container(
              child: Text("HAMAAADD"),
              width: 400,
              height: 600,
              color: Colors.black,
              margin: EdgeInsets.only(right: 5, left: 10, bottom: 20, top: 15),
            ),
          ],
        ),
      ),
    );
  }
}
