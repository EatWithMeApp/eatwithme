import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/pages/interests/interests.dart';
import 'package:eatwithme/main.dart';
import 'package:eatwithme/widgets/loadingCircle.dart';
import 'package:eatwithme/pages/auth/auth.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String uID = 'XAozq9M5DqTgs7TVL1G3JI4Rbns2';
  final Firestore _firestore = Firestore.instance;
  final StreamController _profileController = StreamController();
  TextEditingController _textEditControl = new TextEditingController();
  List<String> userInterests = [
    'interest 1',
    'interest 2',
    'interest 3',
    'interest 4',
    'interest 5'
  ];

  @override
  void initState() {
    super.initState();
    _profileController.addStream(_firestore
        .collection('Users')
        .document(uID)
        .snapshots()
        .map((snap) => snap.data));
  }

  @override
  void dispose() {
    _profileController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('at build');
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
                return Scaffold(
                  appBar: AppBar(
                    title: Text('Profile Page'),
                    backgroundColor: Colors.deepOrange,
                    elevation: 0.0,
                  ),
                  body: ListView(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                      Material(
                        child: showProfilePhoto(usersSnapshot.data['photoURL']),
                        borderRadius: BorderRadius.all(Radius.circular(62.5)),
                        clipBehavior: Clip.hardEdge,
                      ),
                          // Hero(
                          //     tag: 'images/testpic.jpeg',
                          //     child: Container(
                          //       height: 125.0,
                          //       width: 125.0,
                          //       decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(62.5),
                          //           image: DecorationImage(
                          //               fit: BoxFit.cover,
                          //               image:
                          //                   AssetImage('images/testpic.jpeg'))),
                          //     )),
                          SizedBox(height: 10.0), //Spacing between elements
                          SizedBox(
                              height: 15.0,
                              child: RaisedButton(
                                child: Text('Change Picture'),
                                elevation: 5.0,
                                color: Colors.deepOrange,
                                onPressed: () {
                                  //TODO allow user to change profile picture
                                },
                              )),
                          SizedBox(
                            height: 25.0,
                          ),
                          Text(usersSnapshot.data['displayName']),
                          SizedBox(height: 25.0),
                          Container(
                              padding: EdgeInsets.only(left: 25.0, right: 25.0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black)),
                              child: TextField(
                                enabled: true,
                                maxLength: 250,
                                maxLengthEnforced: true,
                                decoration:
                                    InputDecoration(hintText: 'About Me'),
                                controller: _textEditControl,
                              )),
                          Container(
                              height: 100.0,
                              child: ListView.builder(
                                  itemCount: List.of(usersSnapshot.data['interests']).length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                        child: Text(List.of(usersSnapshot.data['interests']).elementAt(index)));
                                  })),
                          SizedBox(height: 5.0),
                          SizedBox(
                              height: 15.0,
                              child: RaisedButton(
                                child: Text('Edit Interests'),
                                elevation: 5.0,
                                color: Colors.deepOrange,
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Interests()));
                                },
                              )),
                          SizedBox(
                            height: 25.0,
                          ),
                          RaisedButton(
                            child: Text('SAVE'),
                            elevation: 5.0,
                            color: Colors.deepOrange,
                            onPressed: () {
                              submitProfile();
                            },
                          ),
                        ],
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

submitProfile() {
  //Save the about me section and profile picture to firebase
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

// Widget buildInterestsList(AsyncSnapshot chatSnapshot, String currentUid) {
//   //Check for no chats
//   //If not checked, an empty list will get built over any
//   //messages we want to show
//   if (chatSnapshot.data.documents.length == 0) {
//     return noActiveProfile();
//   }

//   return ListView.separated(
//     separatorBuilder: (context, index) => Divider(
//           color: Colors.black,
//         ),
//     padding: EdgeInsets.all(0.0),
//     itemBuilder: (context, index) => Friend(
//         uid: getUidFromChatSnapshot(
//             chatSnapshot.data.documents[index], currentUid)),
//     itemCount: chatSnapshot.data.documents.length,
//   );
// }