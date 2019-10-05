import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/pages/interests/interest_list.dart';
import 'package:eatwithme/services/db.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InterestPage extends StatefulWidget {
  final String uid;
  final ValueChanged<Set<Interest>> updateParentInterests;

  const InterestPage(
      {Key key, @required this.uid, @required this.updateParentInterests})
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
          title: Text(
                  "Interests",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600

                  ),
          ),
          backgroundColor: Color(0xFFFF7922),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
          body: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 10.0, bottom: 10),
                width: sizeX,
                height: sizeY,
                color: Color(0xFFFF7922),
                child: Column(
                  children: <Widget>[

                    Padding(
                      child: Text(
                        "Choose some things you would be interested in talking about.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w400

                        ),
                      ),
                      padding: EdgeInsets.only(left: 30, right: 30),  

                    ),
                    
                    Padding(padding: EdgeInsets.all(15),
                    child: TextField(
                        controller: interest,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          focusColor: Colors.white,
                          labelText: "Search",
                          hintText: "Search",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100.0)))),
                      ),
                    ),
                    
                    InterestList(
                      addInterest: _addInterest,
                      removeInterest: _removeInterest,
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  constraints: BoxConstraints(maxHeight: 80, maxWidth: 1000),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 30),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF7922),
                    boxShadow: [BoxShadow(blurRadius: 4, offset: Offset(0, -4), color: Color.fromRGBO(0, 0, 0, 0.3))], 
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: RaisedButton(
                    child: Text('Save',
                    style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,

                      ),
                    ),
                    elevation: 2.0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20.0),
                      ),
                    onPressed: () {
                      setState(() {
                        widget.updateParentInterests(loggedInInterests);
                        db.updateUserInterests(widget.uid, loggedInInterests);
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              )     
            ],
          )
      )         
    );
  }
}
