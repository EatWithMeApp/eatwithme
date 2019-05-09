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
  var photoUrl;
  AnimationController _animationController;

  @override
  initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
  }

Widget buildCard(displayName, interests){
  Widget card = new Container(
    color: Colors.white,
    child: new ListTile(
            onTap: () => print('hi'),
            onLongPress: () => {},
            leading: CircleAvatar(
              backgroundImage: NetworkImage('https://i.stack.imgur.com/Dw6f7.png'),
            ),
            title: Text(displayName),
            subtitle: Text(interests.toString()),
          ),
  );
  return card;
}

// new ListTile(
//             onTap: () => {},
//             onLongPress: () => {},
//             leading: CircleAvatar(
//               backgroundImage: NetworkImage('https://i.stack.imgur.com/Dw6f7.png'),
//             ),
//             title: Text(displayName),
//             subtitle: Text(interests.toString()),
//           );

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
     return buildCard(displayName, interestss);
   },
 );
}

  @override
  Widget build(BuildContext context) {
    return _buildBody(context, 'u6225609');
  }
}