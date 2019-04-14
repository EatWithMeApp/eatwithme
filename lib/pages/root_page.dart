//Adapted from https://github.com/bizz84/coding-with-flutter-login-demo/blob/master/lib/root_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/auth/auth.dart';
import 'package:eatwithme/pages/home.dart';
import 'package:eatwithme/pages/login/login.dart';
import 'package:eatwithme/auth/auth_provider.dart';

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final BaseAuth auth = AuthProvider.of(context).auth;
    return StreamBuilder<FirebaseUser>(
        stream: auth.onAuthStateChanged,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final bool isLoggedIn = snapshot.hasData;
            return isLoggedIn ? HomePage() : LoginPage();
          }
          return _buildWaitingScreen();
        });
  }

  //This will be the loading screen
  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
