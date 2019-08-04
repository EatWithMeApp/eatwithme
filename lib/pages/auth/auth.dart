//Adapted from https://github.com/tattwei46/flutter_login_demo/blob/master/lib/services/authentication.dart
//Adapted from https://www.youtube.com/watch?v=cHFV6JPp-6A

import 'dart:async';
import 'package:eatwithme/utils/verification_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseAuth {
  Future<FirebaseUser> login(String email, String password);
  Future<FirebaseUser> signUp(String email, String password);
  Future<void> sendEmailVerification();
  Future<String> signOut();
  bool isEmailVerified();
  Future<void> sendPasswordResetEmail(String userEmail);
  Observable<Map<String, dynamic>> getUserProfile(String uid);
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  Observable<FirebaseUser> user;
  Observable<Map<String, dynamic>> userProfile;
  PublishSubject loading = PublishSubject();

  String currentUid;

  Auth() {
    user = Observable(_firebaseAuth.onAuthStateChanged);

    //Pull user profile from FireStore
    userProfile = user.switchMap((FirebaseUser u) {
      if (u != null) {
        return _firestore
            .collection('Users')
            .document(u.uid)
            .snapshots()
            .map((snap) => snap.data);
      } else {
        return Observable.just({ });
      }
    });
  }

  Future<FirebaseUser> login(String email, String password) async {
    try {
      loading.add(true);
      FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
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
      FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      currentUid = user.uid;

      await user.sendEmailVerification();
      
      makeUserProfile(user);
      print('Signing up user ' + user.email);

      //_firebaseAuth.onAuthStateChanged;

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

  Future<String> signOut() async {
    try {
      currentUid = null;
      await _firebaseAuth.signOut();
      return 'SignOut';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  bool isEmailVerified() {
    // FirebaseUser user = await _firebaseAuth.currentUser();
    // return user.isEmailVerified;
    bool verified = false;
    _firebaseAuth.currentUser().then((user) => {
      print(user.isEmailVerified),
      verified = user.isEmailVerified
      });
    return verified;
  }

  Future<void> sendPasswordResetEmail(String userEmail) async {
    return _firebaseAuth.sendPasswordResetEmail(email: userEmail);
  }

  void updateUserProfile(FirebaseUser user) async {
    currentUid = user.uid;
    
    DocumentReference ref = _firestore.collection('Users').document(user.uid);

    //TODO: Fix rewrite/lack of saving of fields (needs a profile edit page)
    //Will probably need to read in a Map<String,dynamic> and use those values
    return ref.setData({
      //'uid': user.uid,
      //'email': user.email,
      //'photoURL': user.photoUrl,
      //'displayName': user.displayName,
      'lastSeen': DateTime.now(),
    }, merge: true);
  }

  void makeUserProfile(FirebaseUser user) async {
    //currentUid = user.uid;
    
    DocumentReference ref = _firestore.collection('Users').document(user.uid);

    //TODO: Fix rewrite/lack of saving of fields (needs a profile edit page)
    //Will probably need to read in a Map<String,dynamic> and use those values
    return ref.setData({
      'uid': user.uid,
      'email': user.email,
      'photoURL': user.photoUrl,
      'displayName': user.email.split('@')[0].trim(),
      'lastSeen': DateTime.now(),
    }, merge: true);
  }

  void refreshUser() {
    _firebaseAuth.currentUser().then((user) => {user.reload()});
    print("Refresh");
  }
}

final Auth authService = Auth();
