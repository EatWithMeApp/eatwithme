//Adapted from https://github.com/bizz84/coding-with-flutter-login-demo/blob/master/lib/main.dart

import 'package:eatwithme/pages/root.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:eatwithme/pages/intro/splash_screen.dart';
import 'package:eatwithme/pages/intro/intro_screen.dart';
import 'package:eatwithme/utils/matchFriends.dart';

var routes = <String, WidgetBuilder>{
  "/intro": (BuildContext context) => IntroScreen(),
  "/root" : (BuildContext context) => RootPage(),
};

void main() => runApp(new MaterialApp(
    title: APP_TITLE,
    theme: themeLight(),
    home: SplashScreen(),
    routes: routes));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: APP_TITLE,
        theme: themeLight(),
        home: RootPage(),
      );
  }
}
