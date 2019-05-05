//Adapted from https://github.com/bizz84/coding-with-flutter-login-demo/blob/master/lib/root_page.dart

import 'package:eatwithme/widgets/loadingCircle.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/pages/auth/auth.dart';
import 'package:eatwithme/pages/home.dart';
import 'package:eatwithme/map/map.dart';
import 'package:eatwithme/pages/login/login.dart';

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: authService.user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final bool isLoggedIn = snapshot.hasData;
            return isLoggedIn ? MyMap() : LoginPage();
          }
          return _buildWaitingScreen();
        });
  }

  //TODO: replace with EatWithMe animated face
  Widget _buildWaitingScreen() {
    var scaffold = Scaffold(
      body: LoadingCircle(),
    );
    return scaffold;
  }
}
