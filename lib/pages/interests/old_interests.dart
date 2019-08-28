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
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;
    TextEditingController interest;
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
                      padding: EdgeInsets.only(top: 10.0),
                      width: sizeX,
                      height: sizeY,
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: interest,
                            decoration: InputDecoration(
                              labelText: "Search",
                              hintText: "Search",
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)))
                            ),
                          ),
                          // new DropdownButton(
                          //     value: dropdownValue,
                          //     onChanged: (newValue) {
                          //       setState(() {
                          //        dropdownValue = newValue; 
                          //       });
                          //     },
                          //     items: interestList.map((value) {
                          //       return new DropdownMenuItem(
                          //         child: Text(value),
                          //         value: value,
                          //       );
                          //     }).toList()),
                          
                          new RaisedButton(
                            child: Text("Add Interest"),
                            elevation: 5.0,
                            color: Colors.deepOrange,
                            onPressed: () {
                              if(usersInterests.length < 5)
                                usersInterests.add(interest.toString());
                            },
                          ),
                          Expanded(
                              child: ListView.builder(
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
                                  child: ListTile(title: Text('${usersInterests[index]}'), 
                                  trailing: Icon(Icons.delete),
                                  onTap: ()
                                  {
                                    usersInterests.remove(usersInterests[index]);
                                    print(usersInterests);
                                  },
                                  ),
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
