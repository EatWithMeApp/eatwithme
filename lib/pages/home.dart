import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/* Widget _HomeScreen() {
    return new StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return new SplashScreen();
        } else {
          if (snapshot.hasData) {
            return new MainScreen(firestore: firestore,
                uuid: snapshot.data.uid);
          }
          return new LoginScreen();
        }
      }
    );
} */