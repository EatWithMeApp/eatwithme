import 'dart:async';
import 'dart:core';

import 'package:eatwithme/pages/profile/profile.dart';
import 'package:eatwithme/services/db.dart';
import 'package:eatwithme/utils/routeFromRight.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/pages/interests/old_interests.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  final String uid;

  const EditProfilePage({Key key, @required this.uid}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<EditProfilePage> {
  final db = DatabaseService();

  final TextEditingController _aboutMeController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final StorageReference storageReference =
      FirebaseStorage.instance.ref();

  String aboutMe;
  String displayName;
  String photoURL;

  double imgYPos = 45.0;
  double imgWidth = 200.0;
  double imgHeight = 200.0;
  double imgXPos = 100.0;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    //Uploads image to firebase storage
    final StorageUploadTask uploadTask = storageReference.child(widget.uid).putFile(image);

    photoURL = await (await uploadTask.onComplete).ref.getDownloadURL();

    setState(() {
      db.updateUserPhoto(widget.uid, photoURL);
    });
  }

  @override
  void initState() {
    super.initState();

    print('Edit profile start');

    db.getUser(widget.uid).then((user) {
      setState(() {
        var about = user.aboutMe;
        var name = user.displayName;

        aboutMe = about;
        _aboutMeController.text = about;

        displayName = name;
        _displayNameController.text = name;

        photoURL = user.photoURL;

        print('InitState editprofile');
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
    return SafeArea(
      child: ListView(
        children: <Widget>[
          Container(
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      height: 150.0,
                    ),
                    Card(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          alignment: Alignment(0.0, 1.0),
                          height: 150.0,
                          width: 500.0,
                          color: Color(0x00333333),
                          child: TextField(
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.account_circle),
                                helperText: "Your display name"),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold),
                            controller: _displayNameController,
                            onChanged: (text) {
                              setState(() {
                                displayName = text;
                              });
                            },
                            maxLines: 1,
                            maxLength: 20,
                            maxLengthEnforced: true,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            top: 5.0,
                          ),
                          child: Text(
                            'About',
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                          alignment: Alignment(-1.0, 0.0),
                        ),
                        Container(
                          child: TextField(
                            decoration:
                                InputDecoration(border: OutlineInputBorder()),
                            keyboardType: TextInputType.multiline,
                            maxLength: 500,
                            maxLengthEnforced: true,
                            maxLines: null,
                            onChanged: (text) {
                              setState(() {
                                aboutMe = text;
                              });
                            },
                            controller: _aboutMeController,
                          ),
                        ),
                        Row(
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
                            SizedBox(
                              width: 20.0,
                            ),
                            Container(
                              alignment: Alignment(1.0, 0.0),
                              padding: EdgeInsets.only(top: 10.0),
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.push(context,
                                      RouteFromRight(widget: Interests()));
                                },
                                color: Colors.orange,
                                child: Text('Edit Interests'),
                              ),
                            ),
                          ],
                        ),
                        Container(
                            height: 75.0,
                            child: ProfileInterestsList(
                              interests: [], //List.of(usersSnapshot.data['interests'] ?? [])
                            )

                            // ListView.builder(
                            //     scrollDirection: Axis.horizontal,
                            //     itemCount: List.of(
                            //             usersSnapshot.data['interests'])
                            //         .length,
                            //     itemBuilder:
                            //         (BuildContext context, int index) {
                            //       return ButtonBar(
                            //         alignment: MainAxisAlignment.start,
                            //         children: <Widget>[
                            //           RaisedButton(
                            //             onPressed: null,
                            //             elevation: 5.0,
                            //             child: Text('#' +
                            //                 List.of(usersSnapshot
                            //                         .data['interests'])
                            //                     .elementAt(index)),
                            //           ),
                            //         ],
                            //       );
                            //     })

                            ),
                        SaveButton(
                          aboutMe: aboutMe,
                          displayName: displayName,
                        )
                      ],
                    )),
                  ],
                ),
                UserImage(
                  imgHeight: imgHeight,
                  imgWidth: imgWidth,
                  photoURL: photoURL,
                ),
                Positioned(
                  top: imgYPos + 120.0,
                  // left: imgXPos + 150.0,
                  child: FlatButton(
                    color: Colors.orange,
                    child: Text('Edit Picture'),
                    onPressed: () {
                      getImage();
                    },
                  ),
                ),
                CloseButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
    @required this.aboutMe,
    @required this.displayName,
  }) : super(key: key);

  final String aboutMe;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    var db = DatabaseService();
    var loggedInUser = Provider.of<FirebaseUser>(context);
    return Container(
      padding: EdgeInsets.only(top: 25.0),
      width: 200.0,
      child: FlatButton(
        color: Colors.orange,
        child: Text('Save'),
        onPressed: () {
          try {
            db.updateUserProfileText(loggedInUser.uid, aboutMe, displayName);
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