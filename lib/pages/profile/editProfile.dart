import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/pages/profile/profile.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:eatwithme/utils/routeFromRight.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/pages/interests/interests.dart';
import 'package:eatwithme/main.dart';
import 'package:eatwithme/widgets/loadingCircle.dart';
import 'package:eatwithme/services/auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  final String uid;

  const EditProfilePage({Key key, this.uid}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<EditProfilePage> {
  // String uid = 'Oaag40RDDDLof3sjq5QW';
  var downloadURL;
  final Firestore _firestore = Firestore.instance;
  // final StreamController _profileController = StreamController();
  final TextEditingController _aboutMeController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final StorageReference storageReference =
      FirebaseStorage.instance.ref().child('ProfilePicture');

  DocumentSnapshot usersSnapshot;

  String aboutMe;
  String displayName;

  File _image;
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    setState(() {
      _image = image;
    });
    //Uploads image to firebase storage
    final StorageUploadTask uploadTask = storageReference.putFile(_image);
    downloadURL = await (await uploadTask.onComplete).ref.getDownloadURL();

    setState(() {
      Firestore.instance
          .collection('Users')
          .document(widget.uid)
          .setData(
        {
          'photoURL': downloadURL,
        },
        merge: true,
      );
    });
  }

  double imgYPos = 45.0;
  double imgWidth = 200.0;
  double imgHeight = 200.0;
  double imgXPos = 100.0;

  @override
  void initState() {
    super.initState();

    print('Edit profile start');

    // Read from DB just once as opposed to stream - otherwise we'll never get to save...
    _firestore.collection('Users').document(widget.uid).get().then((snap) {
      setState(() {
        usersSnapshot = snap;

        var about = usersSnapshot.data['aboutMe'] ?? '';
        var name = usersSnapshot.data['displayName'] ?? '';

        aboutMe = about;
        _aboutMeController.text = about;

        displayName = name;
        _displayNameController.text = name;

        downloadURL = usersSnapshot.data['photoURL'] ?? PROFILE_PHOTO_PLACEHOLDER_PATH;
      });
    });
  }

  @override
  void dispose() {
    _aboutMeController?.dispose();
    _displayNameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
    // Set initial values on first load
    // return SafeArea(
    //   child: ListView(
    //     children: <Widget>[
    //       Container(
    //         child: Stack(
    //           alignment: Alignment.topCenter,
    //           children: <Widget>[
    //             Column(
    //               children: <Widget>[
    //                 Container(
    //                   height: 150.0,
    //                 ),
    //                 Card(
    //                     child: Column(
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: <Widget>[
    //                     Container(
    //                       alignment: Alignment(0.0, 1.0),
    //                       height: 150.0,
    //                       width: 500.0,
    //                       color: Color(0x00333333),
    //                       child: TextField(
    //                         decoration: InputDecoration(
    //                             prefixIcon: Icon(Icons.account_circle),
    //                             helperText: "Your display name"),
    //                         style: TextStyle(
    //                             color: Colors.black,
    //                             fontSize: 30.0,
    //                             fontWeight: FontWeight.bold),
    //                         controller: _displayNameController,
    //                         onChanged: (text) {
    //                           setState(() {
    //                             displayName = text;
    //                           });
    //                         },
    //                         maxLines: 1,
    //                         maxLength: 20,
    //                         maxLengthEnforced: true,
    //                       ),
    //                     ),
    //                     Container(
    //                       padding: EdgeInsets.only(
    //                         top: 5.0,
    //                       ),
    //                       child: Text(
    //                         'About',
    //                         style: TextStyle(
    //                             fontSize: 20.0, fontWeight: FontWeight.bold),
    //                       ),
    //                       alignment: Alignment(-1.0, 0.0),
    //                     ),
    //                     Container(
    //                       child: TextField(
    //                         decoration:
    //                             InputDecoration(border: OutlineInputBorder()),
    //                         keyboardType: TextInputType.multiline,
    //                         maxLength: 500,
    //                         maxLengthEnforced: true,
    //                         maxLines: null,
    //                         onChanged: (text) {
    //                           setState(() {
    //                             aboutMe = text;
    //                           });
    //                         },
    //                         controller: _aboutMeController,
    //                       ),
    //                     ),
    //                     Row(
    //                       children: <Widget>[
    //                         Container(
    //                           padding: EdgeInsets.only(top: 10.0),
    //                           child: Text(
    //                             'Interests',
    //                             style: TextStyle(
    //                                 fontSize: 20.0,
    //                                 fontWeight: FontWeight.bold),
    //                           ),
    //                           alignment: Alignment(-1.0, 0.0),
    //                         ),
    //                         SizedBox(
    //                           width: 20.0,
    //                         ),
    //                         Container(
    //                           alignment: Alignment(1.0, 0.0),
    //                           padding: EdgeInsets.only(top: 10.0),
    //                           child: FlatButton(
    //                             onPressed: () {
    //                               Navigator.push(context,
    //                                   RouteFromRight(widget: Interests()));
    //                             },
    //                             color: Colors.orange,
    //                             child: Text('Edit Interests'),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                     Container(
    //                         height: 75.0,
    //                         child: ProfileInterestsList(
    //                           interests: [], //List.of(usersSnapshot.data['interests'] ?? [])
    //                         )

    //                         // ListView.builder(
    //                         //     scrollDirection: Axis.horizontal,
    //                         //     itemCount: List.of(
    //                         //             usersSnapshot.data['interests'])
    //                         //         .length,
    //                         //     itemBuilder:
    //                         //         (BuildContext context, int index) {
    //                         //       return ButtonBar(
    //                         //         alignment: MainAxisAlignment.start,
    //                         //         children: <Widget>[
    //                         //           RaisedButton(
    //                         //             onPressed: null,
    //                         //             elevation: 5.0,
    //                         //             child: Text('#' +
    //                         //                 List.of(usersSnapshot
    //                         //                         .data['interests'])
    //                         //                     .elementAt(index)),
    //                         //           ),
    //                         //         ],
    //                         //       );
    //                         //     })

    //                         ),
    //                     SaveButton(
    //                       uid: widget.uid,
    //                       aboutMe: aboutMe,
    //                       displayName: displayName,
    //                     )
    //                   ],
    //                 )),
    //               ],
    //             ),
    //             UserImage(
    //               imgHeight: imgHeight,
    //               imgWidth: imgWidth,
    //               photoURL: usersSnapshot.data['photoURL'],
    //             ),
    //             // FadeInImage.assetNetwork(
    //             //   placeholder: PROFILE_PHOTO_PLACEHOLDER_PATH,
    //             //   fadeInCurve: SawTooth(1),
    //             //   image: downloadURL,
    //             //   width: 125.0,
    //             //   height: 125.0,
    //             //   fit: BoxFit.fitHeight,
    //             // ),
    //             Positioned(
    //               top: imgYPos + 120.0,
    //               // left: imgXPos + 150.0,
    //               child: FlatButton(
    //                 color: Colors.orange,
    //                 child: Text('Edit Picture'),
    //                 onPressed: () {
    //                   getImage();
    //                 },
    //               ),
    //             ),
    //             CloseButton(),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     body: Column(
  //       children: <Widget>[
  //         Container(
  //           // height: 400.0,
  //           child: Column(
  //             mainAxisSize: MainAxisSize.max,
  //             children: <Widget>[
  //               Container(
  //                 height: 100.0,
  //                 decoration: BoxDecoration(
  //                     color: Color(0xFF333333),
  //                     borderRadius: BorderRadius.only(
  //                       topLeft: const Radius.circular(10.0),
  //                       topRight: const Radius.circular(10.0),
  //                     )),
  //                 child: Text(
  //                   (usersSnapshot.data['displayName'] ??
  //                       usersSnapshot.data['email']
  //                           .toString()
  //                           .split('@')[0]
  //                           .trim()),
  //                   style: TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 30.0,
  //                       fontWeight: FontWeight.bold),
  //                 ),
  //                 alignment: Alignment(0.0, 1.0),
  //               ),
  //               Container(
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   border: Border.all(
  //                     color: Colors.transparent,
  //                     width: 0.0
  //                   )
  //                 ),
  //                 child: Column(
  //                   children: <Widget>[
  //                     SizedBox(
  //                       height: 10.0,
  //                     ),
  //                     Container(
  //                       child: Text(
  //                         'About',
  //                         style: TextStyle(
  //                             fontSize: 20.0, fontWeight: FontWeight.bold),
  //                       ),
  //                       alignment: Alignment(-1.0, 0.0),
  //                     ),
  //                     Container(
  //                       // height: 110.0,
  //                       padding: EdgeInsets.only(
  //                         top: 10.0,
  //                       ),
  //                       constraints: BoxConstraints(
  //                           maxHeight: 90.0,
  //                           minHeight: 50.0,
  //                           maxWidth: double.infinity,
  //                           minWidth: double.infinity),
  //                       child: Text(
  //                         (usersSnapshot.data['aboutMe'] ?? ''),
  //                       ),
  //                     ),
  //                     Container(
  //                       child: Column(
  //                         children: <Widget>[
  //                           Container(
  //                             padding: EdgeInsets.only(top: 10.0),
  //                             child: Text(
  //                               'Interests',
  //                               style: TextStyle(
  //                                   fontSize: 20.0, fontWeight: FontWeight.bold),
  //                             ),
  //                             alignment: Alignment(-1.0, 0.0),
  //                           ),
  //                           InterestsList(
  //                             interests: (usersSnapshot.data['interests'] != null) ? List.of(usersSnapshot.data['interests']) : [],
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }
}

class CloseButton extends StatelessWidget {
  const CloseButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment(1.0, -1.0),
        child: FlatButton(
          child: Icon(Icons.close, size: 30.0),
          textColor: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ));
  }
}

class SaveButton extends StatelessWidget {
  const SaveButton({
    Key key,
    @required this.uid,
    @required this.aboutMe,
    @required this.displayName,
  }) : super(key: key);

  final String uid;
  final String aboutMe;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 25.0),
      width: 200.0,
      child: FlatButton(
        color: Colors.orange,
        child: Text('Save'),
        onPressed: () {
          try {
            submitProfileChanges(uid, aboutMe, displayName);
          } catch (e) {
            print(e);
          } finally {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

void submitProfileChanges(String uid, String aboutMe, String displayName) {
  print('submitProfileChanges ' + displayName);

  Firestore.instance.collection('Users').document(uid).setData(
    {
      'displayName': displayName,
      'aboutMe': aboutMe,
    },
    merge: true,
  );
}

Widget showProfilePhoto(String profileURL) {
  //If there is a photo, we have to pull and cache it, otherwise use the asset template

  if (profileURL == null) {
    profileURL = PROFILE_PHOTO_PLACEHOLDER_PATH;
  }

  // if (profileURL != null) {
  return FadeInImage.assetNetwork(
    placeholder: PROFILE_PHOTO_PLACEHOLDER_PATH,
    fadeInCurve: SawTooth(1),
    image: profileURL,
    width: 125.0,
    height: 125.0,
    fit: BoxFit.fitHeight,
  );
  // } else {
  //   return Image.asset(
  //     PROFILE_PHOTO_PLACEHOLDER_PATH,
  //     width: 125.0,
  //     height: 125.0,
  //     fit: BoxFit.scaleDown,
  //   );
  // }
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
