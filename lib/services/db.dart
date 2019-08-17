import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class DatabaseService {
  final Firestore _db = Firestore.instance;
  final Geoflutterfire _geo = Geoflutterfire();

  Future<User> getUser(String id) async {
    var snapshot = await _db.collection('Users').document(id).get();

    return User.fromFirestore(snapshot);
  }

  Stream<User> streamUser(String id) {
    return _db
        .collection('Users')
        .document(id)
        .snapshots()
        .map((snap) => User.fromMap(snap.data));
  }

  // Stream<List<User>> streamSubcollection(FirebaseUser user) {
  //   var ref = _db.collection('Users').document(user.uid).collection('ChatRooms');

  //   return ref.snapshots().map((list) =>
  //     list.documents.map((doc) => User.fromFirestore(doc))
  //   );
  // }

  Stream<Iterable<User>> streamNearbyUsers(
      String loggedInUid, GeoFirePoint loggedInPosition) {
    // Grab all users within our radius 
    
    // TODO: filter us out here
    // TODO: eventually pass a list of users that we share interests with and restrict checks to them

    return _geo
        .collection(collectionRef: _db.collection('Users'))
        .within(
            center: loggedInPosition,
            radius: USER_LOCATION_RADIUS,
            field: 'position',
            strictMode: true)
        .map((list) => list.map((doc) => User.fromFirestore(doc)));
  }

  Stream<Iterable<ChatRoom>> streamChatRoomsOfUser(FirebaseUser user) {
    return _db
        .collectionGroup('ChatRooms')
        .where('userUids', arrayContains: user.uid)
        .snapshots()
        .map(
            (list) => list.documents.map((doc) => ChatRoom.fromFirestore(doc)));
  }

  Stream<Iterable<Message>> streamMessagesFromChatRoom(
      String roomId, String loggedInUid) {
    return _db
        .collection('ChatRooms')
        .document(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((list) => list.documents.map((doc) => Message.fromFirestore(doc)));
  }

  Future<ChatRoom> getChatRoom(String id) async {
    var snapshot = await _db.collection('ChatRooms').document(id).get();

    return ChatRoom.fromFirestore(snapshot);
  }

  Stream<User> streamUserInChatRoom(String roomId, String loggedInUid) {
    var uids = roomId.split('-');
    uids.remove(loggedInUid);

    return streamUser(uids.first);
  }

  Future<void> updateUserLocation(String uid, GeoFirePoint point) {
    return _db
        .collection('Users')
        .document(uid)
        .setData({'position': point.data}, merge: true);
  }

  Future<void> updateLoggedInUser(String uid) {
    return _db
        .collection('Users')
        .document(uid)
        .setData({'lastSeen': DateTime.now()}, merge: true);
  }

  Future<void> createNewUser(FirebaseUser verifiedUser) {
    return _db.collection('Users').document(verifiedUser.uid).setData({
      'uid': verifiedUser.uid,
      'email': verifiedUser.email,
      'photoURL': verifiedUser.photoUrl,
      'displayName': verifiedUser.email.split('@')[0].trim(),
      'lastSeen': DateTime.now(),
    }, merge: true);
  }

  Future<void> verifyChatRoom(List<String> userUids) async {
    String id = ChatRoom.generateID(userUids);
    var room = _db.collection('ChatRooms').document(id);

    return room.get().then((doc) {
      if (doc.exists == false) {
        createChatRoom(id, userUids);
      }
    }).catchError((doc) {
      if (!doc.exists) {
        createChatRoom(id, userUids);
      }
    });
  }

  Future<void> createChatRoom(String roomId, List<String> userUids) {
    var room = _db.collection('ChatRooms').document(roomId);

    return room.setData({
      'id': roomId,
      'userUids': userUids,

      // Rooms with 2 users are user to user and shouldn't allow others
      'canAddUsers': (userUids.length != 2),
    }, merge: true);
  }

  Future<void> writeMessageToChatRoom(List<String> userUids, Message message) {
    verifyChatRoom(userUids);    

    String id = ChatRoom.generateID(userUids);
    var room = _db.collection('ChatRooms').document(id);

    //Write message to the messages subcollection
    var documentReference = room.collection('messages').document();

    message.id = documentReference.documentID;

    return _db.runTransaction((transaction) async {
      await transaction.set(documentReference, message.toMap());
    });
  }
}
