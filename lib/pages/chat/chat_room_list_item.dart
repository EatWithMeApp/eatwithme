import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/pages/chat/chat_room.dart';
import 'package:eatwithme/pages/profile/profile.dart';
import 'package:eatwithme/services/db.dart';
import 'package:eatwithme/utils/routeFromRight.dart';
import 'package:eatwithme/widgets/profile_photo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatRoomListItem extends StatelessWidget {
  const ChatRoomListItem({Key key, @required this.roomId})
      : super(key: key);

  final String roomId;

  @override
  Widget build(BuildContext context) {
    var db = DatabaseService();
    var loggedInUid = Provider.of<FirebaseUser>(context);
    
    if (roomId == '$loggedInUid-$loggedInUid') return Container();

    return StreamProvider<User>.value(
      value: db.streamUser(roomId),
      child: ChatRoomCard(),
    );
  }
}

class ChatRoomCard extends StatelessWidget {
  const ChatRoomCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User>(context);

    if (user == null) return Container();

    return Container(
      child: FlatButton(
        child: Row(
          children: <Widget>[
            UserPhoto(user: user),
            Flexible(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        '${user.displayName}',
                        style: TextStyle(color: Colors.black, fontSize: 20.0),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                    ),
                    Container(
                      child: ProfileInterestsList(interests: user.interests),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                    )
                  ],
                ),
                margin: EdgeInsets.only(top: 10.0, left: 0.0),
              ),
            ),
          ],
        ),
        onPressed: () {
          Navigator.push(context, RouteFromRight(widget: ChatRoomPage(peerId: user.uid,)));
        },
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
      ),
      margin: EdgeInsets.only(top: 0.0, left: 10.0, right: 0.0),
    );
  }
}

class UserPhoto extends StatelessWidget {
  const UserPhoto({
    Key key,
    @required this.user,
  }) : super(key: key);

  final User user;
  final double _photoWidth = 80.0;
  final double _photoHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ProfilePhoto(
        profileURL: user.photoURL,
        width: _photoWidth,
        height: _photoHeight,
      ).getWidget(),
      borderRadius: BorderRadius.all(Radius.circular(180.0)),
      clipBehavior: Clip.hardEdge,
    );
  }
}
