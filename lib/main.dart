//Adapted from https://github.com/bizz84/coding-with-flutter-login-demo/blob/master/lib/main.dart

import 'package:flutter/material.dart';
import 'package:eatwithme/auth/auth.dart';
import 'package:eatwithme/auth/auth_provider.dart';
import 'package:eatwithme/pages/root_page.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:simple_auth_flutter/simple_auth_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SimpleAuthFlutter.init(context);
    return AuthProvider(
      auth: Auth(),
      child: MaterialApp(
        title: 'EatWithMe',
        theme: themeLight(),
        home: RootPage(),
      ),
    );
  }
}