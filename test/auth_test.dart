import 'package:test/test.dart';
import 'package:eatwithme/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:eatwithme/services/db.dart';

void main() {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  group("test bundles of login/out, sign in/out, and verified email systems \n", (){
    test("test the process from sign up to sign out", (){
    final testAuth = AuthService();
    String email = "u6225609@anu.edu.au";
    String password = "123456";

    testAuth.signUp(email, password);
    testAuth.login(email, password);
    bool emailVerified = testAuth.isEmailVerified();
    expect(false, emailVerified);
    testAuth.sendPasswordResetEmail(email);
    testAuth.sendEmailVerification();
    testAuth.signOut();
    });
  }); 
}