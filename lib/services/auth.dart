//Adapted from https://github.com/tattwei46/flutter_login_demo/blob/master/lib/services/authentication.dart
//Adapted from https://www.youtube.com/watch?v=cHFV6JPp-6A

import 'dart:async';
import 'package:eatwithme/services/db.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  DatabaseService db = DatabaseService();

  Future<void> login(String email, String password) async {
    try {
      var result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      FirebaseUser user = result.user;
      db.updateLoggedInUser(user.uid);

      print('Signed in ' + user.email);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      var result = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      FirebaseUser user = result.user;
      await user.sendEmailVerification();
      db.createNewUser(user);

      print('Signing up user ' + user.email);
    } catch (e) {
      throw e;
    }
  }

  Future<String> signOut() async {
    try {
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
    bool verified = false;
    _firebaseAuth.currentUser().then((user) =>
        {print(user.isEmailVerified), verified = user.isEmailVerified});
    return verified;
  }

  Future<void> sendPasswordResetEmail(String userEmail) async {
    return _firebaseAuth.sendPasswordResetEmail(email: userEmail);
  }
}