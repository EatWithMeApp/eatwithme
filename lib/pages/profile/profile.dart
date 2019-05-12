import 'dart:async';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/pages/interests/interests.dart';
import 'package:eatwithme/main.dart';
import 'package:eatwithme/widgets/loadingCircle.dart';
import 'package:eatwithme/pages/auth/auth.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({Key key, this.uid}) : super(key: key);
  
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String uID = 'XAozq9M5DqTgs7TVL1G3JI4Rbns2';
  final Firestore _firestore = Firestore.instance;
  final StreamController _profileController = StreamController();
  final TextEditingController _chatController = TextEditingController();

  double imgYPos = 45.0;
  double imgWidth = 200.0;
  double imgHeight = 200.0;
  double imgXPos = 100.0;

  @override
  void initState() {
    super.initState();
    _profileController.addStream(_firestore
        .collection('Users')
        .document(widget.uid)
        .snapshots()
        .map((snap) => snap.data));
  }

  @override
  void dispose() {
    print('Close profile');
    _profileController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _profileController.stream,
        builder: (context, usersSnapshot) {
          switch (usersSnapshot.connectionState) {
            case ConnectionState.none:
              return Text("Error loading profile");
              break;
            case ConnectionState.done:
              return noActiveProfile();
            case ConnectionState.waiting:
              return LoadingCircle();
              break;
            case ConnectionState.active:
              if (usersSnapshot.hasData) {
                //return Scaffold(
                return ListView(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              height: 114.0,
                            ),
                            Card(
                                child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  height: 160.0,
                                  width: 500.0,
                                  color: Color(0xFF333333),
                                  child: Text(
                                    (usersSnapshot.data['displayName'] ?? usersSnapshot.data['email'].toString().split('@')[0]),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  alignment: Alignment(0.0, 1.0),
                                ),
                                SizedBox(
                                  height: 25.0,
                                ),
                                Container(
                                  child: Text(
                                    'About',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  alignment: Alignment(-1.0, 0.0),
                                ),
                                Container(
                                  height: 110.0,
                                  child: Text(
                                    (usersSnapshot.data['aboutMe'] ?? ''),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    'Interests',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  alignment: Alignment(-1.0, 0.0),
                                ),
                                Container(
                                    height: 75.0,
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: List.of(
                                                usersSnapshot.data['interests'])
                                            .length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return ButtonBar(
                                            alignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              RaisedButton(
                                                onPressed: null,
                                                elevation: 5.0,
                                                child: Text('#' +
                                                    List.of(usersSnapshot
                                                            .data['interests'])
                                                        .elementAt(index)),
                                              ),
                                            ],
                                          );
                                        })),
                                Container(
                                  padding: EdgeInsets.only(top: 25.0),
                                  child: TextField(
                                    maxLength: 150,
                                    maxLengthEnforced: true,
                                    controller: _chatController,
                                    onSubmitted:
                                        SendChat(uID, _chatController.text),
                                    decoration: InputDecoration(
                                        labelText: 'Say Hi!',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0))),
                                  ),
                                )
                              ],
                            )),
                          ],
                        ),
                        Positioned(
                          top: imgYPos,
                          left: imgXPos,
                          height: imgHeight,
                          width: imgWidth,
                          child: GestureDetector(
                            onTap: () {
                              enlargeImage();
                            },
                            child: Material(
                              child: showProfilePhoto(
                                  usersSnapshot.data['photoURL']),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                //Shouldn't reach here, but assume no chats instead of broken
                return noActiveProfile();
              }
              break;
          }
        });
  }
}

enlargeImage() {
  //TODO find out a way to blow up image size
}

SendChat(String recipientUID, String message) {
  //TODO Send the chat to this user
}

Widget showProfilePhoto(String profileURL) {
  //If there is a photo, we have to pull and cache it, otherwise use the asset template
  if (profileURL != null) {
    //TODO: Implement Firestore image pull
    return FadeInImage.assetNetwork(
      placeholder: PROFILE_PHOTO_PLACEHOLDER_PATH,
      fadeInCurve: SawTooth(1),
      image: profileURL,
      width: 125.0,
      height: 125.0,
      fit: BoxFit.fitHeight,
    );
  } else {
    return Image.asset(
      PROFILE_PHOTO_PLACEHOLDER_PATH,
      width: 125.0,
      height: 125.0,
      fit: BoxFit.scaleDown,
    );
  }
}

Widget noActiveProfile() {
  return Container(
    alignment: Alignment.center,
    child: Text(
      'Error 404',
      softWrap: true,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 25.0,
      ),
    ),
  );
}
