import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class User extends Equatable{
  final String uid;
  final String aboutMe;
  final String displayName;
  final String email;
  final DateTime lastSeen;
  final String photoURL;
  final Set<Interest> interests;
  final GeoFirePoint position;

  User({this.uid, this.aboutMe, this.displayName, this.email, this.lastSeen, this.photoURL, this.interests, this.position});

  factory User.fromMap(Map data) {
    GeoPoint pos = data['position']['geopoint'];
    Set<Interest> userInterests = Set();
    String userEmail = data['email'];
    Timestamp timestamp = data['lastSeen'];

    for (var interest in data['interests']) {
      if (interest.runtimeType == String) continue;

      userInterests.add(Interest.fromMap(interest));
    }

    return User(
      aboutMe: data['aboutMe'] ?? '(Not provided)',
      email: userEmail ?? '(No email available)',
      displayName: data['displayName'] ?? (userEmail.split('@')[0].trim() ?? '') ?? '',
      position: GeoFirePoint(pos.latitude, pos.longitude) ?? null,
      uid: data['uid'] ?? '',
      photoURL: data['photoURL'] ?? '',
      lastSeen: DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch) ?? DateTime.now(),
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

  Map<String, dynamic> toMap() {
    return {
      'aboutMe': aboutMe,
      'email': email,
      'displayName': displayName,
      'position': position,
      'uid': uid,
      'photoURL': photoURL,
      'lastSeen': lastSeen,
      'interests': interests,
    };
  }

}

class ChatRoom extends Equatable {
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

  String getOtherUser(String myUid) {
    // Can only use this for inter-user rooms
    if (userUids.length != 2) return null;

    // We only want the other user if we're actually in this room
    if (!userUids.contains(myUid)) return null;

    return userUids.where((uid) => uid != myUid).first;
  }
}

enum MessageType {
  text,
  image,
  sticker,
}

class Message extends Equatable{
  String id;
  final MessageType type;
  final String content;
  final String uidFrom;
  final DateTime timestamp;

  Message({this.type, this.content, this.uidFrom, this.timestamp, this.id});

  factory Message.fromMap(Map data) {
    Timestamp timestamp = data['timestamp'];
    
    return Message(
      id: data['id'] ?? '',
      type: MessageType.values[data['type']] ?? MessageType.text,
      content: data['content'] ?? '',
      uidFrom: data['uidFrom'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch) ?? DateTime.now(),
    );
  }

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    data['id'] = doc.documentID;
    return Message.fromMap(data);
  } 

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'content': content,
      'uidFrom': uidFrom,
      'timestamp': timestamp,
    };
  }

  bool isPrevMessageSameSide(Message previousMessage, String loggedInUid) {
    return (previousMessage.uidFrom == loggedInUid) == (uidFrom == loggedInUid);
  }

  bool isMessageSameUser(Message message, String uid) {
    return message.uidFrom == uid;
  }

  bool isMessageFromUser(String uid) {
    return uidFrom == uid;
  }

  bool isPeerMessage(String loggedInUid) {
    // A peer message is one not sent by us
    return !isMessageSameUser(this, loggedInUid);
  }

  bool shouldDrawPeerProfilePhoto(Message mostRecentMessage, String loggedInUid) {
    // Draw if we are not the logged in user and either 
    // have a different user to the most recent message or are the most recent ourselves
    return (!isMessageFromUser(loggedInUid)) && (uidFrom != mostRecentMessage.uidFrom || id == mostRecentMessage.id);
  }

}

class Interest extends Equatable{
  String id;
  final String name;
  List<Interest> interests;

  Interest({this.name, this.id, this.interests});

  void addSubInterests(List<Interest> subInterests) {
    interests.addAll(subInterests);
    interests = interests.toSet().toList();
  }

  factory Interest.fromMap(Map data) {
    return Interest(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      interests: [] ?? [], // Add sub interests another time
    );
  }

  factory Interest.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    data['id'] = doc.documentID;
    return Interest.fromMap(data);
  } 

  @override
  String toString() {
    return "$name";
  }

  Map<String, String> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Interest &&
    runtimeType == other.runtimeType &&
    name == other.name;

  @override
  int get hashCode => name.hashCode;
}