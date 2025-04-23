import 'package:flutter/material.dart';

void showErrorAlert(
  String message,
  BuildContext context, {
  Color color = Colors.red,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Align(
        alignment: Alignment.center,
        child: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      duration: Duration(seconds: 1),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    ),
  );
}
