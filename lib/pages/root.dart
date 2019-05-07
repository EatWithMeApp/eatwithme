//Adapted from https://github.com/bizz84/coding-with-flutter-login-demo/blob/master/lib/root_page.dart

import 'dart:async';

import 'package:eatwithme/pages/login/verify.dart';
import 'package:eatwithme/widgets/loadingCircle.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/pages/auth/auth.dart';
import 'package:eatwithme/pages/home.dart';
import 'package:eatwithme/pages/login/login.dart';

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {   
    return StreamBuilder(
        stream: authService.user,
        builder: (context, snapshot) {         
          final bool uidLoaded = authService.currentUid != null;
          if (snapshot.connectionState == ConnectionState.active) {           
            final bool isLoggedIn = snapshot.hasData;
            if (isLoggedIn) {
              // Wait for user to be made/logged in, then show home
              if (uidLoaded) {
                //If verified, go home otherwise make sure they verify
                Widget screen = VerifyPage();

                screen = (snapshot.data.isEmailVerified) ? HomePage() : VerifyPage();

                return screen;
              }
            } else {
              return LoginPage();
            }
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
