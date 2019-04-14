/* 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Widget _HomeScreen() {
    return new StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return new SplashScreen();
        } else {
          if (snapshot.hasData) {
            return new MainScreen(firestore: firestore,
                uuid: snapshot.data.uid);
          }
          return new LoginScreen();
        }
      }
    );
} */

//Adapted from https://github.com/bizz84/coding-with-flutter-login-demo/blob/master/lib/home_page.dart
//This will be the map screen

import 'package:flutter/material.dart';
import 'package:eatwithme/auth/auth.dart';
import 'package:eatwithme/auth/auth_provider.dart';

class HomePage extends StatelessWidget {

  Future<void> _signOut(BuildContext context) async {
    try {
      final BaseAuth auth = AuthProvider.of(context).auth;
      await auth.signOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        actions: <Widget>[
          FlatButton(
            child: Text('Logout', style: TextStyle(fontSize: 17.0, color: Colors.white)),
            onPressed: () => _signOut(context),
          )
        ],
      ),
      body: Container(
        child: Center(child: Text('Welcome', style: TextStyle(fontSize: 32.0))),
      ),
    );
  }
}
