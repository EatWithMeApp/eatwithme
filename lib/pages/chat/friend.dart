import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Friend extends StatefulWidget {
  final String uid;

  const Friend({Key key, @required this.uid}) : super(key: key);

  @override
  _FriendState createState() => _FriendState();
}

class _FriendState extends State<Friend> {
  final Firestore _firestore = Firestore.instance;
  final StreamController _friendController = StreamController();

  @override
  void initState() {
    super.initState();
    print('${widget.uid}');
    _friendController.addStream(_firestore.collection('Users').document(widget.uid).snapshots().map((snap) => snap.data));
  }

  @override
  void dispose() async {
    super.dispose();
    _friendController.close();
  }
  
  @override
  Widget build(BuildContext context) {
    return Text(widget.uid);
  }
}