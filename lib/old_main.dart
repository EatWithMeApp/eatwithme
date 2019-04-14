import 'package:flutter/material.dart';

import 'package:eatwithme/pages/login/login.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:eatwithme/utils/constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: APP_TITLE,
      home: new LoginPage(),
      theme: themeLight(),
    );
  }
}