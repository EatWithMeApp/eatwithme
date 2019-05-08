//Adapted from https://github.com/bizz84/coding-with-flutter-login-demo/blob/master/lib/main.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/pages/root.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:eatwithme/pages/intro/splash_screen.dart';
import 'package:eatwithme/pages/intro/intro_screen.dart';
import 'package:eatwithme/utils/matchFriends.dart';
import 'package:eatwithme/map/map.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  var routes = <String, WidgetBuilder>{
    "/intro": (BuildContext context) => IntroScreen(),
    "/root": (BuildContext context) => RootPage(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_TITLE,
      theme: themeLight(),
      routes: routes,
      home: SplashScreen(),
    );
  }
}
