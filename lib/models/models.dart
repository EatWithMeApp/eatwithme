import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';

class User {

  final String aboutMe;
  final String displayName;
  final String email;
  final DateTime lastSeen;
  final String photoURL;
  final List<String> interests;
  final GeoFirePoint position;

  User({this.aboutMe, this.displayName, this.email, this.lastSeen, this.photoURL, this.interests, this.position});

  factory User.fromMap(Map data) {
    //TODO: Update display naem to take first part of email by default
    return User(
      displayName: data['displayName'] ?? '',
      position: data['position'] ?? null,
    );
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    //id?

    return User.fromMap(data);
  }

}