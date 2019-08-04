import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';

class User {

  final String uid;
  final String aboutMe;
  final String displayName;
  final String email;
  final DateTime lastSeen;
  final String photoURL;
  final List<String> interests;
  final GeoFirePoint position;

  User({this.uid, this.aboutMe, this.displayName, this.email, this.lastSeen, this.photoURL, this.interests, this.position});

  User intialData() {
    //TODO: Implement initial data
    return null;
  }

  factory User.fromMap(Map data) {
    GeoPoint pos = data['position']['geopoint'];
    List<String> userInterests = data['interests'].cast<String>();
    String userEmail = data['email'];

    return User(
      aboutMe: data['aboutMe'] ?? '(Not provided)',
      email: userEmail ?? '(No email available)',
      displayName: data['displayName'] ?? (userEmail.split('@')[0].trim() ?? ''),
      position: GeoFirePoint(pos.latitude, pos.longitude) ?? null,
      uid: data['uid'] ?? '',
      photoURL: data['photoURL'] ?? '',
      lastSeen: DateTime.now() ?? data['lastSeen'],
      interests: userInterests ?? [],
    );
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    data['uid'] = doc.documentID;
    return User.fromMap(data);
  }

}