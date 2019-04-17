//Adapted from https://github.com/bizz84/coding-with-flutter-login-demo/blob/master/lib/home_page.dart

import 'package:eatwithme/pages/chat/friends.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/pages/auth/auth.dart';
import 'package:eatwithme/pages/auth/auth_provider.dart';

class HomePage extends StatelessWidget {
  Future<void> _signOut(BuildContext context) async {
    try {
      final BaseAuth auth = AuthProvider.of(context).auth;
      await auth.logout();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EatWithMe Main'),
        actions: <Widget>[
          FlatButton(
            child: Text('Logout',
                style: TextStyle(fontSize: 17.0, color: Colors.white)),
            onPressed: () => _signOut(context),
          )
        ],
      ),
      body: Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Replace this page with a map',
              style: TextStyle(fontSize: 32.0)),
          SizedBox(
            height: 5.0,
          ),
          Container(
              child: StreamBuilder(
            stream: AuthProvider.of(context).auth.getCurrentUserProfile(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: <Widget>[
                    Text(
                      snapshot.data.toString(),
                      softWrap: true,
                    ),
                  ],
                );
              } else {
                return Container(
                  child: Text("Didn't load user"),
                );
              }
            },
          )),
          FlatButton(
              child: Text('FriendsPage'),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FriendsPage()));
              })
        ],
      )),
    );
  }
}
