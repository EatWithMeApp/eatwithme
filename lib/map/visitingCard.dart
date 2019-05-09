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

  Widget buildCard(displayName, interests){
    Widget card = new Card(
      child: new Column(
        children: <Widget>[
          new ListTile(
            onTap: () => {},
            onLongPress: () => {},
            leading: CircleAvatar(
              backgroundImage: NetworkImage('https://i.stack.imgur.com/Dw6f7.png'),
            ),
            title: Text(displayName),
            subtitle: Text(interests.toString()),
          )
        ],
      ),
    );
    return card;
  }

Widget _buildBody(BuildContext context, String name) {
 return StreamBuilder<QuerySnapshot>(
   stream: Firestore.instance.collection('Users').where("displayName", isEqualTo: name).snapshots(),
   builder: (context, snapshot) {
     if (!snapshot.hasData) return LinearProgressIndicator();
     var name = snapshot.data.documents;
     name.forEach((DocumentSnapshot ds) => {
       displayName = ds.data['displayName'],
       interestss = ds.data['interests']
     });
     return buildCard(displayName, interestss);
   },
 );
}

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
      ),
      body: _buildBody(context, 'u6225609'),
    );
  }
}