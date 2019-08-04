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

  Stream<List<User>> streamFriends(FirebaseUser user) {
    var ref = _db.collection('Users').document(user.uid).collection('Chats');

    return ref.snapshots().map((list) =>
      list.documents.map((doc) => User.fromFirestore(doc))
    );
  }

  Future<void> updateUserLocation(String uid, GeoFirePoint point) {
    return _db.collection('Users').document(uid).setData(
      {'position': point.data}, merge: true
    );
  }

}