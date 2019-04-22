//Adapted from https://github.com/bizz84/coding-with-flutter-login-demo/blob/master/lib/home_page.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/pages/chat/friends.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/pages/auth/auth.dart';
import 'package:rxdart/rxdart.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //final PublishSubject _subjectUser = PublishSubject<Map<String, dynamic>>();
  Map<String, dynamic> _profile;
  bool _loading = false;

  final Firestore _firestore = Firestore.instance;

  final StreamController _fatController = StreamController();
  final PublishSubject _fatController2 = PublishSubject();

  @override
  void initState() {
    //_subjectUser.addStream(authService.userProfile);

    _fatController.addStream(_firestore
        .collection('Users')
        .document(authService.currentUid)
        .snapshots()
        .map((snap) => snap.data));

    super.initState();
    // _fatController.doOnData((state) => setState(() => _profile = state));
    // _fatController2.addStream(authService.loading);
    // _fatController2.doOnData((state) => setState(() => _loading = state));

    //authService.userProfile.listen((state) => setState(() => _profile = state));
    //authService.loading.listen((state) => setState(() => _loading = state));

    print('${authService.currentUid}');
    print('Home initState done ${_profile.toString()}');
    //_subjectUser.
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      //_subjectUser.controller.close();
      //await _subjectUser.drain();

      //authService.user = null;

      //authService.userProfile = null;
      //authService.loading = null;

      await authService.signOut();
      _fatController.close();

      // _fatController.drain();
      // _fatController2.drain();

      // _fatController2.close();

      //_subjectUser.stream.drain();
      //_subjectUser.close();
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    //await _subjectUser.drain().catchError((x) {print(x.toString());});

    super.dispose();

    print('Finish dispose');
  }

  Widget doShit() {
    if (_profile != null) {
      //currentUid = _profile['uid']; //snapshot.data['uid'];
      return Column(
        children: <Widget>[
          Text(
            _profile.toString(), //snapshot.data.toString(),
            softWrap: true,
          ),
        ],
      );
    } else {
      return Container(
        child: Text("Didn't load user"),
      );
    }
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
            stream: _fatController
                .stream, //authService.user,//_subjectUser.stream, //_streamController.stream,//authService.userProfile,
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
                            builder: (context) => FriendsPage(
                                  currentUid: currentUid,
                                ));
                        Navigator.of(context).push(route);
                        //Navigator.pushNamed(context, '/FriendsPage');
                      })))
        ],
      )),
    );
  }
}
