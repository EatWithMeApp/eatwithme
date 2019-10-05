import 'dart:core';

import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/pages/chat/chat_room.dart';
import 'package:eatwithme/services/db.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:eatwithme/utils/routeFromBottom.dart';
import 'package:eatwithme/widgets/profile_photo.dart';
import 'package:flutter/material.dart';
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
                            interests: user.interests,
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
              ),
              ListTile(
                title: Text('Block User'),
                subtitle:
                    Text('Removes user from map and removes chat history'),
                trailing: Icon(Icons.block),
                onTap: () {
                  //TODO implement user blocking
                },
              )
            ],
          ),
        )
      ],
    );
  }
}

class ProfileInterestsList extends StatefulWidget {
  const ProfileInterestsList({
    Key key,
    @required this.interests,
  }) : super(key: key);

  final Set<Interest> interests;

  @override
  _ProfileInterestsListState createState() => _ProfileInterestsListState();
}

class _ProfileInterestsListState extends State<ProfileInterestsList> {
  @override
  Widget build(BuildContext context) {
    if (widget.interests == null) return Container();

    return Container(
        height: 50.0,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.interests.length,
            itemBuilder: (BuildContext context, int index) {
              var interest = widget.interests.elementAt(index);

              if (interest == null) return Container();

              // return Text('$interestId ');

              return InterestChip(
                interest: interest,
              );
            }));
  }
}

class InterestChip extends StatefulWidget {
  final Interest interest;

  const InterestChip({Key key, @required this.interest}) : super(key: key);

  @override
  _InterestChipState createState() => _InterestChipState();
}

class _InterestChipState extends State<InterestChip> {  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.interest == null) return Container();

    return Chip(
      backgroundColor: Colors.orangeAccent,
      label: Text('#' + widget.interest.name),
    );
  }
}

class ChatboxLink extends StatelessWidget {
  const ChatboxLink({
    Key key,
    @required this.peerID,
  }) : super(key: key);

  final String peerID;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
