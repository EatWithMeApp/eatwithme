import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/pages/chat/friend.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:eatwithme/widgets/loadingCircle.dart';
import 'package:flutter/material.dart';

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
    _controllerChat.addStream(_firestore
        .collection('Chats')
        .where('userUids', arrayContains: widget.currentUid)
        .snapshots());
  }

  @override
  void dispose() async {
    _controllerChat.close();
    super.dispose();
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
                ),
              ),
              Text(
                '  Chats',
                style: TextStyle(fontSize: 20.0),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Container(
            color: Colors.white,
            child: StreamBuilder(
                stream: _controllerChat.stream,
                builder: (context, chatSnapshot) {
                  switch (chatSnapshot.connectionState) {
                    case ConnectionState.none:
                      return Text("Error loading chat");
                      break;
                    case ConnectionState.done:
                      return noActiveChats();
                    case ConnectionState.waiting:
                      return LoadingCircle();
                      break;
                    case ConnectionState.active:
                      if (chatSnapshot.hasData) {
                        return buildFriendList(chatSnapshot, widget.currentUid);
                      } else {
                        //Shouldn't reach here, but assume no chats instead of broken
                        return noActiveChats();
                      }
                      break;
                  }
                }),
          ),
        ));
  }

  Widget buildFriendList(AsyncSnapshot chatSnapshot, String currentUid) {
    //Check for no chats
    //If not checked, an empty list will get built over any
    //messages we want to show
    if (chatSnapshot.data.documents.length == 0) {
      return noActiveChats();
    }

    return ListView.builder(
      // separatorBuilder: (context, index) => Divider(
      //   color: Colors.black87,
      // ),
      padding: EdgeInsets.all(0.0),
      itemBuilder: (context, index) => Friend(
          userUid: currentUid,
          friendUid: getUidFromChatSnapshot(
              chatSnapshot.data.documents[index], currentUid)),
      itemCount: chatSnapshot.data.documents.length,
    );
  }

  Widget noActiveChats() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        NO_ACTIVE_CHATS,
        softWrap: true,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 25.0,
        ),
      ),
    );
  }

  String getUidFromChatSnapshot(DocumentSnapshot snap, String currentUid) {
    List<String> users = List.from(snap.data['userUids']);

    //Just in case the filter doesn't catch a dud/null chat
    if (!users.contains(currentUid)) {
      return null;
    }

    //Remove us, return the other person
    users.remove(currentUid);
    return users[0];
  }
}
