import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:flutter/material.dart';

class Friend extends StatefulWidget {
  final String uid;

  const Friend({Key key, @required this.uid}) : super(key: key);

  @override
  _FriendState createState() => _FriendState();
}

class _FriendState extends State<Friend> {
  final Firestore _firestore = Firestore.instance;
  final StreamController _friendController = StreamController();

  final double _photoWidth = 80.0;
  final double _photoHeight = 80.0;

  Widget buildInterests(List<dynamic> interests) {
    //TODO: add formatting to interests 
    return Text('${interests != null ? interests.toString() : 'No interests listed'}',
        style: TextStyle(color: Colors.black, fontSize: 18.0));
  }

  Widget showProfilePhoto(String profileURL) {
    //If there is a photo, we have to pull and cache it, otherwise use the asset template
    if (profileURL != null) {
      // return CachedNetworkImage(
      //   placeholder: (context, url) => Container(
      //         child: CircularProgressIndicator(
      //             strokeWidth: 1.0,
      //             valueColor:
      //                 null //AlwaysStoppedAnimation<Color>(themeLight().primaryColor),
      //             ),
      //         width: _photoWidth,
      //         height: _photoHeight,
      //         padding: EdgeInsets.all(15.0),
      //       ),
      //   imageUrl: profileURL,
      //   width: _photoWidth,
      //   height: _photoHeight,
      //   fit: BoxFit.fitHeight,
      // );
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
    print('${widget.uid}');

    //TODO: Use authService instead
    _friendController.addStream(_firestore
        .collection('Users')
        .document(widget.uid)
        .snapshots()
        .map((snap) => snap.data));
    super.initState();
  }

  @override
  void dispose() async {
    _friendController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //widget.uid
    return StreamBuilder(
      stream: _friendController.stream,
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
                                child: buildInterests(snapshot.data['interests']),
                                alignment: Alignment.centerLeft,
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                              )
                            ],
                          ),
                          margin: EdgeInsets.only(left: 0.0),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => Chat(
                    //               peerId: userProfile.documentID,
                    //               peerAvatar: userProfile['photoUrl'],
                    //             )));
                  },
                  color: Colors.grey,
                  padding: EdgeInsets.fromLTRB(10.0, 6.0, 0.0, 6.0),
                ),
                margin: EdgeInsets.only(bottom: 0.0, left: 0.0, right: 0.0),
              );
            } else {}
            break;
        }
      },
    );
  }
}
