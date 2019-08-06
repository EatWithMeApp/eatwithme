import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/pages/chat/chat.dart';
import 'package:eatwithme/pages/profile/profile.dart';
import 'package:eatwithme/services/db.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:eatwithme/utils/routeFromRight.dart';
import 'package:eatwithme/widgets/loadingCircle.dart';
import 'package:eatwithme/widgets/profile_photo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Friend extends StatefulWidget {
  final String friendUid;

  const Friend({Key key, @required this.friendUid}) : super(key: key);

  @override
  _FriendState createState() => _FriendState();
}

class _FriendState extends State<Friend> {
  Widget buildInterests(List<dynamic> interests) {
    // Reduce, reuse, recycle ;)
    return ProfileInterestsList(interests: interests);
  }

  @override
  void initState() {
    super.initState();
    // _friendController.addStream(_firestore
    //     .collection('Users')
    //     .document(widget.friendUid)
    //     .snapshots()
    //     .map((snap) => snap.data));
  }

  @override
  void dispose() async {
    // _friendController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var db = DatabaseService();

    return StreamProvider<User>.value(
      value: db.streamUser(widget.friendUid),
      child: FriendCard(),
    );
  }
}

class FriendCard extends StatelessWidget {
  const FriendCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User>(context);

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
          // Navigator.push(
          //     context,
          //     RouteFromRight(
          //         widget: Chat(
          //       userId: widget.userUid,
          //       peerId: widget.friendUid,
          //       peerAvatar: snapshot.data['photoURL'],
          //       peerName: (snapshot.data['displayName'] != null)
          //           ? snapshot.data['displayName']
          //           : snapshot.data['email'],
          //     )));
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
