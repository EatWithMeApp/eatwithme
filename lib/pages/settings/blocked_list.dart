import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/services/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BlockedUsers extends StatefulWidget
{
  @override
  State<StatefulWidget> createState()
  {
    return _BlockedUsersState();
  }
}

class _BlockedUsersState extends State<BlockedUsers>
{
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Blocked Users',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          backgroundColor: Colors.orange[600],
        ),
        // body: blockedUserList(),
      )
    );
  }
}