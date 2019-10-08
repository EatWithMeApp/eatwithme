import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';

import 'package:flutter/widgets.dart';

class ChatNotificationApp extends StatefulWidget {
  @override
  ChatNotification createState() => ChatNotification();
}

class ChatNotification extends State<ChatNotificationApp> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String message;
  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg){
        print("Launched");
      },
      onResume: (Map<String, dynamic> msg){
        print("Resumed");
      },
      onMessage: (Map<String, dynamic> msg){
        print("Messaged");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: true,
        alert: true,
        badge: true,
      )
    );
    _firebaseMessaging.getToken().then((token){
      update(token);
    });
  }

  void update(String token){
    print(token);
    message = token;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {

    return null;
  }
}