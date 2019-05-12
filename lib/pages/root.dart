//Adapted from https://github.com/bizz84/coding-with-flutter-login-demo/blob/master/lib/root_page.dart

import 'dart:async';

import 'package:eatwithme/pages/login/verify.dart';
import 'package:eatwithme/pages/map/map2.dart';
import 'package:eatwithme/widgets/loadingCircle.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/pages/auth/auth.dart';
import 'package:eatwithme/pages/home.dart';
import 'package:eatwithme/pages/map/map.dart';
import 'package:eatwithme/pages/login/login.dart';

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // authService.signOut();
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

                // screen = (snapshot.data.isEmailVerified) ? HomePage() : VerifyPage();
                // screen = (snapshot.data.isEmailVerified) ? MyMap() : VerifyPage();
                screen =
                    (snapshot.data.isEmailVerified) ? Map2() : VerifyPage();

                return screen;
              }
            } else {
              return LoginPage();
            }
            // return isLoggedIn ? MyMap() : LoginPage();
          }

          if (snapshot.hasData) {
            // To reach here, we are logged in but in some sort of stuck state
            // so flush it out by forcing the log out
            print('Flush login');
            authService.signOut();
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
