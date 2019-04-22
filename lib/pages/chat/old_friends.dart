//Adapted from https://github.com/duytq94/flutter-chat-demo/blob/master/lib/main.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/pages/auth/auth.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OldFriendsPage extends StatefulWidget {
  @override
  _OldFriendsPageState createState() => _OldFriendsPageState();
}

class _OldFriendsPageState extends State<OldFriendsPage> {
  final double _photoWidth = 80.0;
  final double _photoHeight = 80.0;

  String getProfilePhoto(Map<String, dynamic> userProfile) {
    String photo = userProfile['photoURL'];

    return (photo != null) ? photo : PROFILE_PHOTO_PLACEHOLDER_PATH;
  }

  Widget showProfilePhoto(Map<String, dynamic> userProfile) {
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

  Widget buildChatUser(BuildContext context, String uid) {
    return StreamBuilder(
      stream: authService.getUserProfile(uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            child: FlatButton(
              child: Row(
                children: <Widget>[
                  Material(
                    child: showProfilePhoto(snapshot.data),
                    borderRadius: BorderRadius.all(Radius.circular(180.0)),
                    clipBehavior: Clip.hardEdge,
                  ),
                  Flexible(
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              '${snapshot.data['email']}',
                              style: chatUserTextStyle(),
                            ),
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                          ),
                          Container(
                            child:
                                //TODO: add formatting to interests
                                Text(
                              '${snapshot.data['interests'] ?? 'No interests listed'}',
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
        } else {
          return Container();
        }
      },
    );
  }

  TextStyle chatUserTextStyle() => TextStyle(
        color: Colors.black,
        fontSize: 18.0,
      );

  @override
  Widget build(BuildContext context) {
    final Firestore firestore = Firestore.instance;
    return Scaffold(
        appBar: AppBar(
          title: Text('Chats'),
        ),
        body: SafeArea(
            child: Container(
                child: StreamBuilder(
          stream: authService.userProfile,
          builder: (context, userSnapshot) {
            print('US: ${userSnapshot.connectionState}');

            switch (userSnapshot.connectionState) {
              case ConnectionState.none:
                return Text("WTF none");
                break;
              case ConnectionState.done:
                return Text("All done bish");
              case ConnectionState.waiting:
                return Text("Hang on");
                break;
              case ConnectionState.active:
                if (userSnapshot.hasData) {
                  return StreamBuilder(
                      stream: firestore.collection('Chats').where('userUids',
                          arrayContains: userSnapshot.data.documents.map((doc) {
                        return doc['uid'];
                      })).snapshots(),
                      builder: (context, chatSnapshot) {
                        print('CS: ${chatSnapshot.data}');
                        if (chatSnapshot.hasData) {
                          return buildChatUsersList(chatSnapshot,
                              userSnapshot.data.documents.map((doc) {
                            return doc['uid'];
                          }));
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
              //default:
            }
          },
        ))));
  }

  String getOtherUserInChat(AsyncSnapshot chatSnapshot, String currentUserUid) {
    List<String> users = chatSnapshot.data['userUids'];
    users.remove(currentUserUid);

    return users[0];
  }

  Widget buildChatUsersList(AsyncSnapshot chatSnapshot, String currentUserUid) {
    if (chatSnapshot.hasData) {
      print('chatSnap has data');
      return ListView.builder(
        padding: EdgeInsets.all(0.0),
        itemBuilder: (context, index) => buildChatUser(
            context, getOtherUserInChat(chatSnapshot, currentUserUid)),
        itemCount: chatSnapshot.data.documents.length,
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
