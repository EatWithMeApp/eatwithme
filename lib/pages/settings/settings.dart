import 'package:eatwithme/pages/settings/blocked_list.dart';
import 'package:eatwithme/services/auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final auth = AuthService();
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings",
        style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('Blocked users'),
              leading: CircleAvatar(
                child: Icon(Icons.block)
              ),
              onTap: ()
              {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => BlockedUsers(),
                ));
              },
            ),
            ListTile(
              title: Text('Logout'),
              leading: CircleAvatar(
                child: Icon(Icons.exit_to_app)
              ),
              onTap: ()
              {
                Navigator.pop(context);
                _signOut(context);
              },
            ),
          ],
        ),
      ),
    );
  }

    Future<void> _signOut(BuildContext context) async {
    try {
      await auth.signOut();
    } catch (e) {
      print(e);
    }
  }
}