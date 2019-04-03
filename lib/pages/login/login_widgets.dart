//Adapted from https://github.com/iampawan/Flutter-UI-Kit/blob/master/lib/ui/page/login/login_one/login_widget.dart

import 'package:eatwithme/pages/login/login_card.dart';
import 'package:flutter/material.dart';

class LoginWidgets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 100.0,
            ),
            LoginCard(),
            // new Padding(
            //   padding: const EdgeInsets.only(top: 30.0),
            //   child: new Text(
            //     ISRData.forgot_password,
            //     style: new TextStyle(fontWeight: FontWeight.normal),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}