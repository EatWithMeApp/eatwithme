//Adapted from https://github.com/bizz84/coding-with-flutter-login-demo/blob/master/lib/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:eatwithme/pages/auth/auth.dart';

class AuthProvider extends InheritedWidget {
  const AuthProvider({Key key, Widget child, this.auth}) : super(key: key, child: child);
  final BaseAuth auth;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  // static AuthProvider of(BuildContext context) {
  //   return context.inheritFromWidgetOfExactType(AuthProvider);
  // }
}