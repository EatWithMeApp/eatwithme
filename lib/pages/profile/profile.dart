import 'dart:async';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';
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
                // return Scaffold(
                // return ListView(
                //   children: <Widget>[
                return Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          height: 0.0,
                        ),
                        Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Container(
                                height: 100.0,
                                width: 500.0,
                                color: Color(0xFF333333),
                                child: Text(
                                  (usersSnapshot.data['displayName'] ??
                                      usersSnapshot.data['email']
                                          .toString()
                                          .split('@')[0]
                                          .trim()),
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
                                // height: 110.0,
                                padding: EdgeInsets.only(
                                  top: 10.0,
                                ),
                                constraints: BoxConstraints(
                                    maxHeight: 90.0,
                                    minHeight: 40.0,
                                    maxWidth: double.infinity,
                                    minWidth: double.infinity),
                                child: Text(
                                  (usersSnapshot.data['aboutMe'] ??
                                      '(Not provided)'),
                                ),
                              ),
                              Container(
                                alignment: Alignment(0.0, 0.7),
                                child: Column(
                                  children: <Widget>[
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
                                    InterestsList(
                                      interests:
                                          List.of(usersSnapshot.data['interests']),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 25.0,
                              ),
                              Container(
                                child: ChatboxLink(uID: uID),
                                alignment: Alignment(0.0, 1.0),
                              )
                            ],
                          ),
                        )
                        // Card(
                        //   // clipBehavior: Clip.none,

                        //   child:

                        //   ),
                      ],
                    ),
                    // UserImage(
                    //   imgYPos: imgYPos,
                    //   imgXPos: imgXPos,
                    //   imgHeight: imgHeight,
                    //   imgWidth: imgWidth,
                    //   photoURL: usersSnapshot.data['photoURL'],
                    // ),
                  ],
                );
                // ],
                // );
              } else {
                //Shouldn't reach here, but assume no chats instead of broken
                return noActiveProfile();
              }
              break;
          }
        });
  }
}

class InterestsList extends StatelessWidget {
  const InterestsList({
    Key key,
    @required this.interests,
  }) : super(key: key);

  final List<dynamic> interests;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50.0,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: interests.length,
            itemBuilder: (BuildContext context, int index) {
              return Chip(
                label: Text('#' + interests.elementAt(index).toString()),
              );
            }));
  }
}

class ChatboxLink extends StatelessWidget {
  const ChatboxLink({
    Key key,
    @required this.uID,
  }) : super(key: key);

  final String uID;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        // padding: EdgeInsets.only(top: 25.0),
        height: 40.0,
        width: double.infinity,
        child: RaisedButton(
          onPressed: () {
            //TODO: Go to chat
          },
          color: themeLight().primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          child: Text(
            'Say hi!',
            style: TextStyle(fontSize: 20.0),
          ),
        ));
  }
}

class UserImage extends StatelessWidget {
  const UserImage({
    Key key,
    @required this.photoURL,
    @required this.imgYPos,
    @required this.imgXPos,
    @required this.imgHeight,
    @required this.imgWidth,
  }) : super(key: key);

  final String photoURL;
  final double imgYPos;
  final double imgXPos;
  final double imgHeight;
  final double imgWidth;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: imgYPos,
      left: imgXPos,
      height: imgHeight,
      width: imgWidth,
      child: GestureDetector(
        onTap: () {
          enlargeImage();
        },
        child: Material(
          child: showProfilePhoto(photoURL),
          borderRadius: BorderRadius.all(Radius.circular(100.0)),
          clipBehavior: Clip.hardEdge,
        ),
      ),
    );
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
