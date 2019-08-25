import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:eatwithme/pages/profile/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:eatwithme/main.dart';
import 'package:eatwithme/widgets/loadingCircle.dart';
import 'package:eatwithme/services/auth.dart';

class Interests extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InterestsState();
  }
}

class _InterestsState extends State<Interests> {
  final Firestore _firestore = Firestore.instance;
  final StreamController _userController = StreamController();
  final StreamController _interestsListController = StreamController();

  List interestList = new List();
  String dropdownValue = null;

  String uid = 'XAozq9M5DqTgs7TVL1G3JI4Rbns2';
  List usersInterests = [];

  @override
  void initState() {
    super.initState();
    _userController.addStream(_firestore
        .collection('Users')
        .document(uid)
        .snapshots()
        .map((snap) => snap.data));
    _interestsListController.addStream(_firestore
      .collection('InterestCollection')
      .document('InterestList')
      .snapshots()
      .map((snap) => snap.data));
  }

  @override
  void dispose() {
    _interestsListController.close();
    _userController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _interestsListController.stream,
      builder: (context, interestsListSnapshot)
      {
        interestList = List<String>.from(interestsListSnapshot.data['InterestList']);
    return StreamBuilder(
        stream: _userController.stream,
        builder: (context, usersSnapshot) {
          switch (usersSnapshot.connectionState) {
            case ConnectionState.none:
              return Text("Error loading user's interests");
              break;
            case ConnectionState.done:
              return noActiveProfile();
            case ConnectionState.waiting:
              return LoadingCircle();
              break;
            case ConnectionState.active:
              if (usersSnapshot.hasData) {
                usersInterests = usersSnapshot.data['interests'];
                return Scaffold(
                    appBar: AppBar(
                      title: Text('Interests'),
                      backgroundColor: Colors.deepOrangeAccent,
                    ),
                    body: Container(
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Select Your Interests',
                            style: TextStyle(fontSize: 50.0),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Up to 5',
                            style: TextStyle(fontSize: 20.0),
                            textAlign: TextAlign.center,
                          ),
                          new DropdownButton(
                              value: dropdownValue,
                              onChanged: (newValue) {
                                setState(() {
                                 dropdownValue = newValue; 
                                });
                              },
                              items: interestList.map((value) {
                                return new DropdownMenuItem(
                                  child: Text(value),
                                  value: value,
                                );
                              }).toList()),
                          new RaisedButton(
                            child: Text("Add Interest"),
                            elevation: 5.0,
                            color: Colors.deepOrange,
                            onPressed: () {
                              if(usersInterests.length < 5)
                                usersInterests.add(dropdownValue);
                            },
                          ),
                          Expanded(
                              child: new ListView.builder(
                            itemCount: usersInterests.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Dismissible(
                                  key: Key(usersInterests[index]),
                                  onDismissed: (direction) {
                                    setState(() {
                                     usersInterests.remove(usersInterests[index]);
                                     print(usersInterests);
                                    });
                                     
                                  },
                                  child: ListTile(title: Text('${usersInterests[index]}')),
                                  );
                            },
                          )),
                          RaisedButton(
                            child: Text('SAVE'),
                            elevation: 5.0,
                            color: Colors.deepOrange,
                            onPressed: () {
                              submitInterests(_firestore, uid, usersInterests);
                            },
                          ),
                        ],
                      ),
                    ));
              } else {
                //Shouldn't reach here, but assume no chats instead of broken
                return noActiveProfile();
              }
              break;
          }
        });
      }
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

submitInterests(Firestore firestore,String uID, List interests) {
  DocumentReference ref = firestore.collection('Users').document(uID);
  return ref.setData(
    { 
      'interests': interests,
    },
    merge: true,
  );
}
