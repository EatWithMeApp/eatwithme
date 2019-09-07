import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/pages/interests/interest_list.dart';
import 'package:eatwithme/services/db.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InterestPage extends StatefulWidget {
  final String uid;
  final ValueChanged<Set<Interest>> updateParentInterestIds;

  const InterestPage(
      {Key key, @required this.uid, @required this.updateParentInterestIds})
      : super(key: key);

  @override
  _InterestPageState createState() => _InterestPageState();
}

class _InterestPageState extends State<InterestPage> {
  final db = DatabaseService();
  Set<Interest> loggedInInterests;

  @override
  void initState() {
    super.initState();
    db.getUser(widget.uid).then((user) {
      setState(() {
        loggedInInterests = Set<Interest>.from(user.interests);
      });
    });
  }

  _addInterest(Interest interest) {
    setState(() {
      loggedInInterests = Set.from(loggedInInterests)..add(interest);
    });
  }

  _removeInterest(Interest interest) {
    setState(() {
      loggedInInterests = Set.from(loggedInInterests)..remove(interest);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;
    TextEditingController interest;

    return MultiProvider(
      providers: [
        StreamProvider.value(value: db.streamAllInterests()),
        Provider.value(value: loggedInInterests),
      ],
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
                InterestList(
                  addInterest: _addInterest,
                  removeInterest: _removeInterest,
                ),
                RaisedButton(
                  child: Text('Save My Interests'),
                  elevation: 5.0,
                  color: Colors.deepOrange,
                  onPressed: () {
                    setState(() {
                      widget.updateParentInterestIds(loggedInInterests);
                      db.updateUserInterestsFromIds(
                          widget.uid, loggedInInterests);
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          )),
    );
  }
}
