
import 'package:eatwithme/pages/login/login_background.dart';
import 'package:eatwithme/pages/login/login_widgets.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: themeLight().backgroundColor,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[LoginBackground(), LoginWidgets()],
        ));
  }
}
/* child: new Image.asset('images/EatWithMeGuy.png',
                  fit: BoxFit.scaleDown) */
