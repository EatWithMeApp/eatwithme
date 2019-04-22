//Adapted from https://github.com/tattwei46/flutter_login_demo/blob/master/lib/services/authentication.dart
//Adapted from https://www.youtube.com/watch?v=cHFV6JPp-6A

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseAuth {
  Stream<String> get onAuthStateChanged;
  Future<FirebaseUser> login(String email, String password);
  Future<FirebaseUser> signUp(String email, String password);
  Future<void> sendEmailVerification();
  Future<void> logout();
  Future<bool> isEmailVerified();
  Future<void> sendPasswordResetEmail(String userEmail);
  Observable<Map<String, dynamic>> getUserProfile(String uid);
}

class Auth implements BaseAuth {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  Observable<FirebaseUser> user;
  Observable<Map<String, dynamic>> userProfile;
  PublishSubject loading = PublishSubject();

  String currentUid;

  Auth() {
    user = Observable(firebaseAuth.onAuthStateChanged);

    //Pull user profile from FireStore
    userProfile = user.switchMap((FirebaseUser u) {
      if (u != null) {
        return _firestore
            .collection('Users')
            .document(u.uid)
            .snapshots()
            .map((snap) => snap.data);
      } else {
        return Observable.just({});
      }
    });
  }

  @override
  Stream<String> get onAuthStateChanged {
    return firebaseAuth.onAuthStateChanged.map((user) => user?.uid);
  }

  Future<FirebaseUser> login(String email, String password) async {
    try {
      loading.add(true);
      FirebaseUser user = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      updateUserProfile(user);
      print('Signed in ' + user.email);

      loading.add(false);
      return user;
    } catch (e) {
      throw e;
    }
  }

  Future<FirebaseUser> signUp(String email, String password) async {
    try {
      FirebaseUser user = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      updateUserProfile(user);
      print('Registered user ' + user.email);

      return user;
    } catch (e) {
      throw e;
    }
  }

  Observable<Map<String, dynamic>> getUserProfile(String uid) {
    return _firestore
            .collection('Users')
            .document(uid)
            .snapshots()
            .map((snap) => snap.data);
  }

  Future<void> logout() async {
    return firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  Future<void> sendPasswordResetEmail(String userEmail) async {
    return firebaseAuth.sendPasswordResetEmail(email: userEmail);
  }

  void updateUserProfile(FirebaseUser user) async {
    currentUid = user.uid;
    
    DocumentReference ref = _firestore.collection('Users').document(user.uid);

    return ref.setData({
      'uid': user.uid,
      'email': user.email,
      'photoURL': user.photoUrl,
      'displayName': user.displayName,
      'lastSeen': DateTime.now(),
    }, merge: true);
  }
}

final Auth authService = Auth();
