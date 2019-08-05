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

class ChatRoom {
  final String id;
  final List<String> userUids;
  final bool canAddUsers;
  final List<Message> messages;

  ChatRoom({this.id, this.canAddUsers, this.messages, this.userUids});

  factory ChatRoom.fromMap(Map data) {
    return ChatRoom(
      id: data['id'] ?? '',
      canAddUsers: data['canAddUsers'] ?? false,
      messages: data['messages'] ?? [],
      userUids: data['userUids'] ?? [],
    );
  }

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    data['id'] = doc.documentID;
    return ChatRoom.fromMap(data);
  }

  static String generateID(List<String> userUids) {
    // A chat room's ID is the two users joined
    // A blank ID returned will force Firebase to generate one for us
    // (blanks will be handy if there are multiple users in a chat room...)
    return (userUids.length == 2) ? userUids[0] + '-' + userUids[1] : null;
  }
}

class Message {

}