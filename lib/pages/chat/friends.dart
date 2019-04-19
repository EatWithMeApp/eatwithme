//Adapted from https://github.com/duytq94/flutter-chat-demo/blob/master/lib/main.dart

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/pages/auth/auth.dart';
import 'package:eatwithme/pages/auth/auth_provider.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FriendsPage extends StatelessWidget {
  final double _photoWidth = 80.0;
  final double _photoHeight = 80.0;

  String getProfilePhoto(DocumentSnapshot userProfile) {
    String photo = userProfile['photoURL'];

    return (photo != null) ? photo : PROFILE_PHOTO_PLACEHOLDER_PATH;
  }

  Widget showProfilePhoto(DocumentSnapshot userProfile) {
    String photo = userProfile['photoURL'];

    //If there is a photo, we have to pull and cache it, otherwise use the asset template
    if (photo != null) {
      return CachedNetworkImage(
        placeholder: (context, url) => Container(
              child: CircularProgressIndicator(
                  strokeWidth: 1.0,
                  valueColor:
                      null //AlwaysStoppedAnimation<Color>(themeLight().primaryColor),
                  ),
              width: _photoWidth,
              height: _photoHeight,
              padding: EdgeInsets.all(15.0),
            ),
        imageUrl: photo,
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

  Widget buildChatUser(BuildContext context, DocumentSnapshot userProfile,
      String currentUserUid) {
    if (userProfile['uid'] == currentUserUid) {
      return Container();
    }

    return Container(
      child: FlatButton(
        child: Row(
          children: <Widget>[
            Material(
              child: showProfilePhoto(userProfile),
              borderRadius: BorderRadius.all(Radius.circular(180.0)),
              clipBehavior: Clip.hardEdge,
            ),
            Flexible(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        '${userProfile['email']}',
                        style: chatUserTextStyle(),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                    ),
                    Container(
                      child:
                          //TODO: add formatting to interests
                          Text(
                        '${userProfile['interests'] ?? 'No interests listed'}',
                        style: chatUserTextStyle(),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
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
  }

  TextStyle chatUserTextStyle() => TextStyle(
        color: Colors.black,
        fontSize: 18.0,
      );

  @override
  Widget build(BuildContext context) {
    final BaseAuth auth = AuthProvider.of(context).auth;
    final Firestore firestore = Firestore.instance;
    return Scaffold(
        appBar: AppBar(
          title: Text('Chats'),
        ),
        body: SafeArea(
            child: Container(
                child: StreamBuilder(
          stream: firestore.collection('Users').snapshots(),
          builder: (context, usersSnapshot) {
            print('US: ' + usersSnapshot.data.toString());
            if (usersSnapshot.hasData) {
              return StreamBuilder(
                  stream: authService.userProfile,
                  builder: (context, mySnapshot) {
                    print('MS: ' + mySnapshot.data.toString());
                    if (mySnapshot.hasData) {
                      print('mySnapshot has data');
                      return buildChatUsersList(
                          usersSnapshot, mySnapshot.data['uid']);
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              themeLight().primaryColor),
                        ),
                      );
                    }
                  });
            } else {
              return Container();
            }
          },
        ))));
  }

  Widget buildChatUsersList(AsyncSnapshot snapshot, String currentUserUid) {
    if (snapshot.hasData) {
      return ListView.builder(
        padding: EdgeInsets.all(0.0),
        itemBuilder: (context, index) => buildChatUser(
            context, snapshot.data.documents[index], currentUserUid),
        itemCount: snapshot.data.documents.length,
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(themeLight().primaryColor),
        ),
      );
    }
  }
}
