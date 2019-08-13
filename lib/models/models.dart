import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

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

  static GeoFirePoint parseUserLocation(double latitude, double longitude) {
    return GeoFirePoint(latitude, longitude);
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
      userUids: List.from(data['userUids']) ?? [],
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

    String id = '';

    if (userUids.length != 2) return id;

    // To ensure identical IDs no matter order, ID is placed in hash order
    if (userUids[0].hashCode <= userUids[1].hashCode) {
      id = '${userUids[0]}-${userUids[1]}';
    } else {
      id = '${userUids[1]}-${userUids[0]}';
    }

    return id;
  }

  String getOtherUser(String userUid) {
    // Can only use this for inter-user rooms
    if (userUids.length != 2) return null;

    // We only want the other user if we're actually in this room
    if (!userUids.contains(userUid)) return null;

    return userUids.where((uid) => uid != userUid).first;
  }
}

enum MessageType {
  text,
  image,
  sticker,
}

class Message {
  final String id;
  final MessageType type;
  final String content;
  final String uidFrom;
  final DateTime timestamp;

  Message(this.type, this.content, this.uidFrom, this.timestamp, this.id);

  bool isPrevMessageSameSide(Message previousMessage, String loggedInUid) {
    return (previousMessage.uidFrom == loggedInUid) == (uidFrom == loggedInUid);
  }

  bool isMessageSameUser(Message message, String uid) {
    return message.uidFrom == uid;
  }

  bool isMessageFromUser(String uid) {
    return uidFrom == uid;
  }

  bool shouldDrawPeerProfilePhoto(Message mostRecentMessage, String loggedInUid) {
    // Draw if we are not the logged in user and either 
    // have a different user to the most recent message or are the most recent ourselves
    return (!isMessageFromUser(loggedInUid)) && (uidFrom != mostRecentMessage.uidFrom || id == mostRecentMessage.id);
  }

}