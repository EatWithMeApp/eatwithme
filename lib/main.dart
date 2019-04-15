//Adapted from https://github.com/bizz84/coding-with-flutter-login-demo/blob/master/lib/main.dart

import 'package:eatwithme/pages/auth/auth.dart';
import 'package:eatwithme/pages/auth/auth_provider.dart';
import 'package:eatwithme/pages/root.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:eatwithme/utils/constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      auth: Auth(),
      child: MaterialApp(
        title: APP_TITLE,
        theme: themeLight(),
        home: RootPage(),
      ),
    );
  }
}
