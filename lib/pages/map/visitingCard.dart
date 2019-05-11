import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class visitingCard extends StatefulWidget{
  @override
  _animationCard createState() => _animationCard();

}

class _animationCard extends State<visitingCard> with TickerProviderStateMixin{

  Future<void> getInformation(String name) async{
    String displayName;
    List<String> interest;
    QuerySnapshot db = await Firestore.instance.collection("Users").where("displayName", isEqualTo: name).getDocuments();
    var list = db.documents;
    list.forEach((DocumentSnapshot ds) => {
      displayName = ds.data['displayName'],
      interest = ds.data['interests'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return null;
  }
}