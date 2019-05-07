import 'package:eatwithme/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/pages/auth/auth.dart';

class VerifyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => {authService.signOut()},
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          child: Text(
            VERIFY_ACCOUNT,
            softWrap: true,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25.0,
            ),
          ),
        ));
  }
}
