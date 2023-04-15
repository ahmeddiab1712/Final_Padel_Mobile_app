import 'package:flutter/cupertino.dart';

class AppButtons extends StatelessWidget {
  final Color textColor;
  final Color backgroundColor;
  final Color boarderColor;
  final String text;
  IconData? icon;
  double size;

  AppButtons(
      {Key? key,
      required this.textColor,
      required this.backgroundColor,
      required this.boarderColor,
      required this.text,
      required this.size,
      this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: Center(
          child: Text(
        text,
        style: TextStyle(color: textColor),
      )),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: boarderColor, width: 1.0)),
    );
  }
}
