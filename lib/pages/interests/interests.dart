import 'package:eatwithme/pages/interests/interest_list.dart';
import 'package:eatwithme/services/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eatwithme/models/models.dart';

class InterestPage extends StatefulWidget {
  final String uid;

  const InterestPage({Key key, @required this.uid}) : super(key: key);

  @override
  _InterestPageState createState() => _InterestPageState();
}

class _InterestPageState extends State<InterestPage> {
  final db = DatabaseService();
  Set<String> loggedInInterestsIds;

  @override
  void initState() {
    super.initState();
    db.getUser(widget.uid).then((user) {
      setState(() {
        loggedInInterestsIds = Set<String>.from(user.interests);
      });
    });
  }

  _addInterest(String interestId) {
    setState(() {
      loggedInInterestsIds.add(interestId);
    });
  }

  _removeInterest(String interestId) {
    setState(() {
      loggedInInterestsIds.remove(interestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;
    TextEditingController interest;

    return StreamProvider.value(
      value: db.streamAllInterests(),
      child: Scaffold(
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
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(25.0)))),
                ),

                // RaisedButton(
                //   child: Text("Add Interest"),
                //   elevation: 5.0,
                //   color: Colors.deepOrange,
                //   onPressed: () {
                //     if(usersInterests.length < 5)
                //       usersInterests.add(interest.toString());
                //   },
                // ),
                // Expanded(
                //     child: ListView.builder(
                //   itemCount: usersInterests.length,
                //   itemBuilder: (BuildContext context, int index) {
                //     return Dismissible(
                //         key: Key(usersInterests[index]),
                //         onDismissed: (direction) {
                //           setState(() {
                //            usersInterests.remove(usersInterests[index]);
                //            print(usersInterests);
                //           });

                //         },
                //         child: ListTile(title: Text('${usersInterests[index]}'),
                //         trailing: Icon(Icons.delete),
                //         onTap: ()
                //         {
                //           usersInterests.remove(usersInterests[index]);
                //           print(usersInterests);
                //         },
                //         ),
                //         );
                //   },
                // )),
                InterestList(addInterest: _addInterest, removeInterest: _removeInterest,),
                RaisedButton(
                  child: Text('SAVE'),
                  elevation: 5.0,
                  color: Colors.deepOrange,
                  onPressed: () {
                    db.updateUserInterestsFromIds(
                        widget.uid, List<String>.from(loggedInInterestsIds)
                        );
                  },
                ),
              ],
            ),
          )),
    );
  }
}
