import 'package:flutter/material.dart';

class MyNavigator {

  static void goToIntro(BuildContext context) {
    Navigator.pushNamed(context, "/intro");
  }

  static void goToRoot(BuildContext context) {
    Navigator.pushNamed(context, "/root");
  }
}
