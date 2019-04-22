//Adapted from https://github.com/bizz84/coding-with-flutter-login-demo/blob/master/lib/home_page.dart

import 'dart:async';

import 'package:eatwithme/pages/chat/friends.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/pages/auth/auth.dart';
import 'package:rxdart/rxdart.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PublishSubject _subjectUser = PublishSubject<Map<String, dynamic>>();

  @override
  void initState() {
    super.initState();
    _subjectUser.addStream(authService.userProfile);
    print('Home initState done ${authService.userProfile.toList().toString()}');
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      dispose();
      await authService.logout();
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() async {
    super.dispose();
    await _subjectUser.drain();
    _subjectUser.close();
  }

  @override
  Widget build(BuildContext context) {
    String currentUid;
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
            stream:
                _subjectUser, //_streamController.stream,//authService.userProfile,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text("WTF none");
                  break;
                case ConnectionState.done:
                  return Text("All done bish");
                case ConnectionState.waiting:
                  return Text("Hang on");
                  break;
                case ConnectionState.active:
                  if (snapshot.hasData) {
                    currentUid = snapshot.data['uid'];
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
                  break;
              }
            },
          )),
          SizedBox(
            height: 20.0,
          ),
          Hero(
              tag: 'FriendPage',
              child: Material(
                  child: IconButton(
                      icon: Icon(Icons.chat),
                      iconSize: 60.0,
                      onPressed: () {
                        var route = MaterialPageRoute(
                          builder: (context) => FriendsPage(currentUid: currentUid,)
                        );
                        Navigator.of(context).push(route);
                        //Navigator.pushNamed(context, '/FriendsPage');
                      })))
        ],
      )),
    );
  }
}
