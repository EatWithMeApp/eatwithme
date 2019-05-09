import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class visitingCard extends StatefulWidget{
  @override
  _animationCard createState() => _animationCard();
}

class _animationCard extends State<visitingCard> with TickerProviderStateMixin{
  String displayName = "";
  List<dynamic> interestss;
  List<dynamic> interests = [];
  bool pressed = false;
  double _height = 60.0;
  double _width = 350.0;
  var photoUrl;
  AnimationController controller;
  Animation<double> animation;

Widget buildcard(displayName, interests){
  String showName = displayName;
  var showInterest = interests;
  Widget card = new AnimatedSize(
    curve: Curves.fastOutSlowIn,
    duration: const Duration(seconds: 1),
    vsync: this,      
      child: new Container(
        color: Colors.white,
        width: _width,
        height: _height,
        child: new ListTile(
            onTap: () => {
              setState(() {          
                if (pressed){
                  pressed = false;
                  _height = 10;
                  _width = 10;
                  showName = "";
                  showInterest = [];
                } else {
                  pressed = true;
                  _height = 60.0;
                  _width = 350.0;
                  showName = displayName;
                  showInterest = interests;
                }
                })
            },
            onLongPress: () => {},
            leading: CircleAvatar(
              backgroundImage: NetworkImage('https://i.stack.imgur.com/Dw6f7.png'),
            ),
            title: Text(showName),
            subtitle: Text(showInterest.toString()),
          ),
      ),
    );
  return card;
}

Widget _buildBody(BuildContext context, String name) {
 return StreamBuilder<QuerySnapshot>(
   stream: Firestore.instance.collection('Users').where("displayName", isEqualTo: name).where("photoUrl").snapshots(),
   builder: (context, snapshot) {
     if (!snapshot.hasData) return LinearProgressIndicator();
     var name = snapshot.data.documents;
     name.forEach((DocumentSnapshot ds) => {
       displayName = ds.data['displayName'],
       interestss = ds.data['interests'],
      //  photoUrl = ds.data['photoUrl']
     });
     return buildcard(displayName, interestss);
   },
 );
}

  @override
  Widget build(BuildContext context) {
    // return _buildBody(context, 'u6225609');
    return _buildBody(context, 'u6225609');
  }
}