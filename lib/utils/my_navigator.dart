import 'package:eatwithme/pages/root.dart';
import 'package:flutter/material.dart';

class MyNavigator {

  static void goToIntro(BuildContext context) {
    Navigator.pushNamed(context, "/intro");
  }

  static void goToRoot(BuildContext context) {
    // Navigator.pushReplacementNamed(context, "/root");
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
      builder: (context) => RootPage()
    ), (_) => false);
  }
}
