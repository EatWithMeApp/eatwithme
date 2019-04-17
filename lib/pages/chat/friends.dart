import 'package:flutter/material.dart';

class FriendsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EatWithMe Friends'),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("FriendsPage"),
            FlatButton(
              child: Text('Back Home'),
              onPressed: () {Navigator.pop(context);} ,
            )
          ],
        ),
      )
    );
  }
}