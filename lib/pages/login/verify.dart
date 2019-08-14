import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/services/auth.dart';

class VerifyPage extends StatelessWidget {
  final AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => {auth.signOut()},
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          color: themeLight().backgroundColor,
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
