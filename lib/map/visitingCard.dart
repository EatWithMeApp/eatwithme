import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class visitingCard extends StatefulWidget{
  @override
  _animationCard createState() => _animationCard();
}

class _animationCard extends State<visitingCard> with TickerProviderStateMixin{
  String displayName = "";
  List<dynamic> interests = [];  
  var photoUrl;

String showInterest(){
  String s = "";
  for (String i in interests){
    s += i + ", ";
  }
  return s;
}

Widget buildCard(displayName, interests) {
  Widget card = new ListTile(
    onTap: () => {},
    onLongPress: () => {},
    leading: CircleAvatar(
      backgroundImage: new AssetImage("images/head_picture_u6225609.png"),
    ),
    title: Text(displayName),
    subtitle: Text(showInterest()),
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
       interests = ds.data['interests'],
      //  photoUrl = ds.data['photoUrl']
     });
     return buildCard(displayName, interests);
   },
 );
}

  @override
  Widget build(BuildContext context) {
    return _buildBody(context, 'u6225609');
  }
}