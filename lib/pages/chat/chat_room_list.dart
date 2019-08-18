import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/pages/chat/chat_room_list_item.dart';
import 'package:eatwithme/services/db.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatRoomListPage extends StatelessWidget {
  ChatRoomListPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loggedInUser = Provider.of<FirebaseUser>(context);
    var db = DatabaseService();

    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Hero(
                tag: 'ChatRoomListPage',
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
              child: StreamProvider<Iterable<ChatRoom>>.value(
                value: db.streamChatRoomsOfUser(loggedInUser),
                child: ChatRoomList(),
              )),
        ));
  }
}

class ChatRoomList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loggedInUser = Provider.of<FirebaseUser>(context);
    var rooms = Provider.of<Iterable<ChatRoom>>(context);

    if (rooms == null || rooms.length == 0) {
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

    return ListView.builder(
      padding: EdgeInsets.all(0.0),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        return ChatRoomListItem(
            roomId: rooms.elementAt(index).getOtherUser(loggedInUser.uid));
      },
    );
  }
}
