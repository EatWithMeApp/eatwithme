import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/models/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class DatabaseService {
  final Firestore _db = Firestore.instance;

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

  Stream<Iterable<ChatRoom>> streamChatRooms(FirebaseUser user) {
    return _db
        .collectionGroup('ChatRooms')
        .where('userUids', arrayContains: user.uid)
        .snapshots()
        .map((list) => list.documents.map((doc) => ChatRoom.fromMap(doc.data)));
  }

  Future<void> updateUserLocation(String uid, GeoFirePoint point) {
    return _db
        .collection('Users')
        .document(uid)
        .setData({'position': point.data}, merge: true);
  }

  Future<void> createChatRoom(List<String> userUids) {
    String id = ChatRoom.generateID(userUids);
    var room = _db.collection('ChatRooms').document(id);

    room.setData({
      'id': id,
      'userUids': userUids,

      // Rooms with 2 users are user to user and shouldn't allow others
      'canAddUsers': (userUids.length != 2),
    }, merge: true);

    //Add the messages subcollection
    return room.collection('messages').document().setData({});
  }
}
