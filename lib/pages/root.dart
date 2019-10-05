//Adapted from https://github.com/bizz84/coding-with-flutter-login-demo/blob/master/lib/root_page.dart

import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/pages/login/verify.dart';
import 'package:eatwithme/pages/map/map.dart';
import 'package:eatwithme/pages/map/map_loading.dart';
import 'package:eatwithme/services/db.dart';
import 'package:eatwithme/widgets/loadingCircle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/pages/login/login.dart';
import 'package:provider/provider.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final db = DatabaseService();
  User loggedInUser;

  Widget _buildWaitingScreen() {
    var scaffold = Scaffold(
      body: LoadingCircle(),
    );
    return scaffold;
  }

  @override
  void initState() {
    super.initState();
  }

  Future<User> loadUser(String uid) async {
    return db.getUser(uid);
  }

  @override
  Widget build(BuildContext context) {
    var firebaseUser = Provider.of<FirebaseUser>(context);

    // Check user logged in and verified
    if (firebaseUser != null) {
      if (firebaseUser.isEmailVerified) {
        loadUser(firebaseUser.uid).then((user) {
          setState(() {
            loggedInUser = user;
          });
        });

        if (loggedInUser != null) {
          if (firebaseUser != null) {
            return StreamProvider.value(
              value: db.getUser(firebaseUser.uid).asStream(),
              catchError: (context, obj) {},
              child: MapPage(),
            );
          } else {
            // We must have logged out
            return LoginPage();
          }
        } else {
          return MapLoading();
        }
      } else {
        return VerifyPage();
      }
    } else {
      return LoginPage();
    }
  }
}
