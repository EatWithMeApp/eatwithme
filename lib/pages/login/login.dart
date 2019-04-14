import 'package:eatwithme/pages/login/login_background.dart';
import 'package:eatwithme/pages/login/login_widgets.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:eatwithme/auth/auth.dart';
import 'package:eatwithme/auth/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => new LoginPageState();
}

enum FormType {
  login,
  register,
}

class LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FormType _formType = FormType.login;

  var deviceSize;
  String azureToken;

  bool validateAndSave() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> validateAndSubmit() async {
    //if (validateAndSave()) {
    try {
      final BaseAuth auth = AuthProvider.of(context).auth;
      print('Made auth');
      if (_formType == FormType.login) {
        final FirebaseUser user = await auth.handleSignIn(); //auth.signInWithAzureToken();
        print('Signed in: $user');
      }
    } catch (e) {
      print('Error: $e');
    }
    //}
  }

  Widget loginBuilder() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: SingleChildScrollView(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // new TextField(
            //   //onChanged: (phone) => phoneNumber = phone,
            //   //enabled: !snapshot.data,
            //   style: new TextStyle(fontSize: 15.0, color: Colors.black),
            //   decoration: new InputDecoration(
            //       hintText: "",
            //       labelText: "Username",
            //       labelStyle: TextStyle(fontWeight: FontWeight.w700)),
            // ),
            // new SizedBox(
            //   height: 10.0,
            // ),
            // new TextField(
            //   //onChanged: (myotp) => otp = myotp,
            //   //keyboardType: TextInputType.number,
            //   style: new TextStyle(fontSize: 15.0, color: Colors.black),
            //   decoration: new InputDecoration(
            //       hintText: "",
            //       labelText: "Password",
            //       labelStyle: TextStyle(fontWeight: FontWeight.w700)),
            //   obscureText: true,
            // ),
            // new SizedBox(
            //   height: 30.0,
            // ),
            new SizedBox(
              height: 30.0,
            ),
            Container(
              child: Text(
                "Welcome to EatWithMe!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: themeLight().primaryColor, offset: Offset(1.0, 1.0))],
                ),
              ),
            ),
            new SizedBox(
              height: 50.0,
            ),
            Container(
              // child: new GradientButton(text: "Login with ANU Email"),
              child: MicrosoftSignInButton(
                borderRadius: 10.0,
                onPressed: validateAndSubmit,
                text: 'Login with ANU Email',
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget loginCard() {
    return Opacity(
      //opacity: animation.value,
      opacity: 1.0,
      child: SizedBox(
        height: deviceSize.height / 2 - 20,
        width: deviceSize.width * 0.85,
        child: new Card(
            color: themeLight().cardColor, elevation: 2.0, child: loginBuilder()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return new Scaffold(
        backgroundColor: Color(0xffeeeeee),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            LoginBackground(),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 100.0,
                    ),
                    loginCard(),
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
