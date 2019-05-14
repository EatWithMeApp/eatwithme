import 'dart:async';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/pages/chat/chat.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:eatwithme/utils/routeFromBottom.dart';
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
  final Firestore _firestore = Firestore.instance;
  final StreamController _profileController = StreamController();

  double imgWidth = 140.0;
  double imgHeight = 140.0;

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
                return Container(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: imgWidth / 2.0),
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: 306.0,
                            maxHeight: 500.0,
                            minWidth: double.infinity,
                            maxWidth: double.infinity,
                          ),
                          child: ProfileCard(
                              widget: widget, usersSnapshot: usersSnapshot),
                        ),
                      ),
                      UserImage(
                        imgHeight: imgHeight,
                        imgWidth: imgWidth,
                        photoURL: usersSnapshot.data['photoURL'],
                      ),
                    ],
                  ),
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

class ProfileCard extends StatelessWidget {
  const ProfileCard(
      {Key key, @required this.widget, @required this.usersSnapshot})
      : super(key: key);

  final ProfilePage widget;
  final AsyncSnapshot usersSnapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          // height: 400.0,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                height: 100.0,
                decoration: BoxDecoration(
                    color: Color(0xFF333333),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0),
                    )),
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.transparent,
                    width: 0.0
                  )
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      child: Text(
                        'About',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
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
                          minHeight: 50.0,
                          maxWidth: double.infinity,
                          minWidth: double.infinity),
                      child: Text(
                        (usersSnapshot.data['aboutMe'] ?? '(Not provided)'),
                      ),
                    ),
                    Container(
                      // alignment: Alignment(0.0, 0.7),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text(
                              'Interests',
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold),
                            ),
                            alignment: Alignment(-1.0, 0.0),
                          ),
                          InterestsList(
                            interests: List.of(usersSnapshot.data['interests']),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.transparent,
                    width: 0.0
                  )
                ),
                child: ChatboxLink(uID: widget.uid, peerName: usersSnapshot.data['displayName'], photoURL: usersSnapshot.data['photoURL']),
              )
            ],
          ),
        )
      ],
    );
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
                backgroundColor: Colors.orangeAccent,
                label: Text('#' + interests.elementAt(index).toString()),
              );
            }));
  }
}

class ChatboxLink extends StatelessWidget {
  const ChatboxLink({
    Key key,
    @required this.uID,
    @required this.peerName,
    @required this.photoURL,
  }) : super(key: key);

  final String uID;
  final String peerName;
  final String photoURL;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        // padding: EdgeInsets.only(top: 25.0),
        height: 40.0,
        width: double.infinity,
        child: FlatButton(
          onPressed: () {
            Navigator.push(
              context,
              RouteFromBottom(widget: Chat(
                userId: authService.currentUid,
                peerId: uID,
                peerName: peerName,
                peerAvatar: photoURL,
              ))
            );
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
    @required this.imgHeight,
    @required this.imgWidth,
  }) : super(key: key);

  final String photoURL;
  final double imgHeight;
  final double imgWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: imgWidth,
      height: imgHeight,
      decoration:
          ShapeDecoration(shape: CircleBorder(), color: Color(0xFF333333)),
      child: Padding(
        padding: EdgeInsets.all(1.1),
        child: DecoratedBox(
          decoration: ShapeDecoration(
              shape: CircleBorder(),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: showProfilePhoto(photoURL, imgWidth, imgHeight))),
        ),
      ),
    );

    // return Positioned(
    //   top: imgYPos,
    //   left: imgXPos,
    //   // height: imgHeight,
    //   // width: imgWidth,
    //   child: GestureDetector(
    //     onTap: () {
    //       enlargeImage();
    //     },
    //     child: Material(
    //       child: showProfilePhoto(photoURL, imgWidth, imgHeight),
    //       borderRadius: BorderRadius.all(Radius.circular(100.0)),
    //       clipBehavior: Clip.hardEdge,
    //     ),
    //   ),
    // );
  }
}

enlargeImage() {
  //TODO find out a way to blow up image size
}

SendChat(String recipientUID, String message) {
  //TODO Send the chat to this user
}

ImageProvider showProfilePhoto(String profileURL, double width, double height) {
  //If there is a photo, we have to pull and cache it, otherwise use the asset template
  if (profileURL != null) {
    //TODO: Implement Firestore image pull
    return FadeInImage.assetNetwork(
      placeholder: PROFILE_PHOTO_PLACEHOLDER_PATH,
      fadeInCurve: SawTooth(1),
      image: profileURL,
      width: width,
      height: height,
      fit: BoxFit.fitHeight,
    ).image;
  } else {
    return Image.asset(
      PROFILE_PHOTO_PLACEHOLDER_PATH,
      width: width,
      height: height,
      fit: BoxFit.scaleDown,
    ).image;
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
