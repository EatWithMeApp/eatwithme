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


// void main() => runApp(new MyApp());

Future<void> main() async{
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'EatWithMeIOS',
    options: const FirebaseOptions(
      googleAppID: '1:1050553742489:ios:d582d6d5c13ccf2c',
      bundleID: 'com.eatwithme.eatwithme',
      projectID: 'eatwithme-c103e',
    ),
  );
  final Firestore firestore = Firestore(app: app);
  await firestore.settings(timestampsInSnapshotsEnabled: true);

  runApp(MyApp());
}

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
