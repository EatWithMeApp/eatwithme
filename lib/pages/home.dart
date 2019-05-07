//Adapted from https://github.com/bizz84/coding-with-flutter-login-demo/blob/master/lib/home_page.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/pages/chat/friends.dart';
import 'package:eatwithme/widgets/loadingCircle.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/pages/auth/auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Firestore _firestore = Firestore.instance;
  final StreamController _controllerUserProfile = StreamController();

  @override
  void initState() {
    
    _controllerUserProfile.addStream(_firestore
        .collection('Users')
        .document(authService.currentUid)
        .snapshots()
        .map((snap) => snap.data));
        super.initState();
        print("initstate");
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await authService.signOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _controllerUserProfile.close();
    super.dispose();
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
            stream: _controllerUserProfile.stream,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text("Error reading profile");
                  break;
                case ConnectionState.done:
                  return Text("Error reading profile");
                case ConnectionState.waiting:
                  return LoadingCircle();
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
                            builder: (context) => FriendsPage(
                                  currentUid: currentUid,
                                ));
                        Navigator.of(context).push(route);
                      })))
        ],
      )),
    );
  }
}
