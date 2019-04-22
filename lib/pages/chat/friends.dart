import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/pages/auth/auth.dart';
import 'package:eatwithme/pages/chat/friend.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class FriendsPage extends StatefulWidget {
  final String currentUid;

  FriendsPage({Key key, @required this.currentUid}) : super(key: key);
  
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final Firestore _firestore = Firestore.instance;
  final StreamController _controllerChat = StreamController();

  @override
  void initState() {
    super.initState();
    _controllerChat.addStream(
      _firestore
          .collection('Chats')
          .where('userUids', arrayContains: widget.currentUid)
          .snapshots()
    );
  }

  @override
  void dispose() async {
    super.dispose();
    _controllerChat.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Hero(
                  tag: 'FriendPage',
                  child: Icon(
                    Icons.chat,
                    size: 35.0,
                  )),
              Text(
                '  Chats',
                style: TextStyle(fontSize: 20.0),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: StreamBuilder(
              stream: _controllerChat.stream,
              builder: (context, chatSnapshot) {
                switch (chatSnapshot.connectionState) {
                  case ConnectionState.none:
                    return Text("WTF none");
                    break;
                  case ConnectionState.done:
                    return Text("All done bish");
                  case ConnectionState.waiting:
                    return Text("Hang on");
                    break;
                  case ConnectionState.active:
                    if (chatSnapshot.hasData) {
                      return buildFriendList(chatSnapshot, widget.currentUid);
                    } else {
                      Text('No friends');
                    }
                    break;
                }
              }),
        ));
  }

  Widget buildFriendList(AsyncSnapshot chatSnapshot, String currentUid) {
    return ListView.builder(
      padding: EdgeInsets.all(0.0),
      itemBuilder: (context, index) => Friend(
          uid: getUidFromChatSnapshot(
              chatSnapshot.data.documents[index], currentUid)),
      itemCount: chatSnapshot.data.documents.length,
    );
  }

  String getUidFromChatSnapshot(DocumentSnapshot snap, String currentUid) {
    print('${snap.data.toString()}');

    List<String> users = List.from(snap.data['userUids']);

    users.remove(currentUid);
    return users[0];
  }
}
