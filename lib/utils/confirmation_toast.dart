import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ConfirmationToast {
  static void show(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.green,
        textColor: Colors.black,
        fontSize: 14.0);
  }
}
