import 'dart:core';

import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/pages/chat/chat_room.dart';
import 'package:eatwithme/services/db.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:eatwithme/utils/routeFromBottom.dart';
import 'package:eatwithme/widgets/profile_photo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/pages/interests/interests.dart';
import 'package:eatwithme/main.dart';
import 'package:eatwithme/widgets/loadingCircle.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({Key key, this.uid}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DatabaseService db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: db.streamUser(widget.uid),
      child: UserProfile(),
    );
  }
}

class UserProfile extends StatelessWidget {
  final double imgWidth = 140.0;
  final double imgHeight = 140.0;

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);

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
              child: ProfileCard(user: user),
            ),
          ),
          UserImage(
              imgHeight: imgHeight,
              imgWidth: imgWidth,
              photoURL: user.photoURL),
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({Key key, @required this.user}) : super(key: key);

  final User user;

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
                  user.displayName,
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
                    border: Border.all(color: Colors.transparent, width: 0.0)),
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
                      child: Text(user.aboutMe),
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
                          ProfileInterestsList(
                            interests: List.of(user.interests),
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
                    border: Border.all(color: Colors.transparent, width: 0.0)),
                child: ChatboxLink(
                  peerID: user.uid,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class ProfileInterestsList extends StatelessWidget {
  const ProfileInterestsList({
    Key key,
    @required this.interests,
  }) : super(key: key);

  final List<String> interests;

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
    @required this.peerID,
    // @required this.peerName,
    // @required this.photoURL,
  }) : super(key: key);

  final String peerID;
  // final String peerName;
  // final String photoURL;

  @override
  Widget build(BuildContext context) {
    // var loggedInUser = Provider.of<FirebaseUser>(context);

    // var db = DatabaseService();

    return SizedBox(
        // padding: EdgeInsets.only(top: 25.0),
        height: 40.0,
        width: double.infinity,
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                RouteFromBottom(
                    widget: ChatRoomPage(
                  peerId: peerID,
                )));
          },
          child: FlatButton(
            onPressed: () {
              Navigator.push(
                  context,
                  RouteFromBottom(
                      widget: ChatRoomPage(
                    peerId: peerID,
                  )));
              // db.createChatRoom([loggedInUser.uid, peerID]);

              // Navigator.push(
              //     context,
              //     RouteFromBottom(
              //         widget: Chat(
              //       userId: loggedInUser.uid,
              //       peerId: peerID,
              //       peerName: peerName,
              //       peerAvatar: photoURL,
              //     )));
            },
            color: themeLight().primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
            child: Text(
              'Say hi!',
              style: TextStyle(fontSize: 20.0),
            ),
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
                image: ProfilePhoto(
                        profileURL: photoURL,
                        width: imgWidth,
                        height: imgHeight)
                    .getImageProvider(),
              )),
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
