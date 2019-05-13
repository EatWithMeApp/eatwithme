import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/pages/chat/chat.dart';
import 'package:eatwithme/pages/profile/profile.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:eatwithme/utils/routeFromRight.dart';
import 'package:eatwithme/widgets/loadingCircle.dart';
import 'package:flutter/material.dart';

class Friend extends StatefulWidget {
  final String userUid;
  final String friendUid;

  const Friend({Key key, @required this.userUid, @required this.friendUid})
      : super(key: key);

  @override
  _FriendState createState() => _FriendState();
}

class _FriendState extends State<Friend> {
  final Firestore _firestore = Firestore.instance;
  final StreamController _friendController = StreamController();

  final double _photoWidth = 80.0;
  final double _photoHeight = 80.0;

  Widget buildInterests(List<dynamic> interests) {
    // Reduce, reuse, recycle ;)
    return InterestsList(interests: interests);
  }

  Widget showProfilePhoto(String profileURL) {
    //If there is a photo, we have to pull and cache it, otherwise use the asset template
    if (profileURL != null) {
      //TODO: Implement Firestore image pull
      return FadeInImage.assetNetwork(
        placeholder: PROFILE_PHOTO_PLACEHOLDER_PATH,
        fadeInCurve: SawTooth(1),
        image: profileURL,
        width: _photoWidth,
        height: _photoHeight,
        fit: BoxFit.fitHeight,
      );
    } else {
      return Image.asset(
        PROFILE_PHOTO_PLACEHOLDER_PATH,
        width: _photoWidth,
        height: _photoHeight,
        fit: BoxFit.scaleDown,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _friendController.addStream(_firestore
        .collection('Users')
        .document(widget.friendUid)
        .snapshots()
        .map((snap) => snap.data));
  }

  @override
  void dispose() async {
    _friendController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _friendController.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text("Error loading chat");
            break;
          case ConnectionState.done:
            return Container();
          case ConnectionState.waiting:
            return LoadingCircle();
            break;
          case ConnectionState.active:
            if (snapshot.hasData) {
              return Container(
                child: FlatButton(
                  child: Row(
                    children: <Widget>[
                      Material(
                        child: showProfilePhoto(snapshot.data['photoURL']),
                        borderRadius: BorderRadius.all(Radius.circular(180.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      Flexible(
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  //If they don't have a display name set, show email
                                  '${snapshot.data['displayName'] ?? snapshot.data['email']}',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20.0),
                                ),
                                alignment: Alignment.centerLeft,
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                              ),
                              Container(
                                child:
                                    buildInterests(snapshot.data['interests']),
                                alignment: Alignment.centerLeft,
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                              )
                            ],
                          ),
                          margin: EdgeInsets.only(top: 10.0, left: 0.0),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        RouteFromRight(
                            widget: Chat(
                          userId: widget.userUid,
                          peerId: widget.friendUid,
                          peerAvatar: snapshot.data['photoURL'],
                          peerName: (snapshot.data['displayName'] != null)
                              ? snapshot.data['displayName']
                              : snapshot.data['email'],
                        )));
                  },
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                ),
                margin: EdgeInsets.only(top: 0.0, left: 10.0, right: 0.0),
              );
            } else {
              return Container();
            }
            break;
        }
      },
    );
  }
}
