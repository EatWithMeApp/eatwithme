//Adapted from https://github.com/bizz84/coding-with-flutter-login-demo/blob/master/lib/root_page.dart

import 'package:eatwithme/pages/login/verify.dart';
import 'package:eatwithme/pages/map/map.dart';
import 'package:eatwithme/services/db.dart';
import 'package:eatwithme/widgets/loadingCircle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/pages/login/login.dart';
import 'package:provider/provider.dart';

class RootPage extends StatelessWidget {

  final db = DatabaseService();

  //TODO: replace with EatWithMe animated face
  Widget _buildWaitingScreen() {
    var scaffold = Scaffold(
      body: LoadingCircle(),
    );
    return scaffold;
  }

  @override
  Widget build(BuildContext context) {
    var firebaseUser = Provider.of<FirebaseUser>(context);

    // Check user logged in and verified
    if (firebaseUser != null) {
      if (firebaseUser.isEmailVerified) {
        return StreamProvider.value(
          value: db.getUser(firebaseUser.uid).asStream(),
          child: MapPage(),
        );
      } else {
        return VerifyPage();
      }
    } else {
      return LoginPage();
    }

  }
}
