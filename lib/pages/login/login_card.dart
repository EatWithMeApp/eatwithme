//Adapted from https://github.com/iampawan/Flutter-UI-Kit/blob/master/lib/ui/page/login/login_one/login_card.dart

import 'package:flutter/material.dart';
import 'package:eatwithme/widgets/gradient_button.dart';
import 'package:flutter/services.dart';

import 'package:simple_auth/simple_auth.dart' as simpleAuth;
import 'package:simple_auth_flutter/simple_auth_flutter.dart';

class LoginCard extends StatefulWidget {
  @override
  _LoginCardState createState() => new _LoginCardState();
}

class _LoginCardState extends State<LoginCard>
    with SingleTickerProviderStateMixin {
  
  var deviceSize;
  Animation<double> animation;
  AnimationController controller;

  static String azureClientId = "e3a62f96-d33f-4964-8fe7-e925129aa3ad";
  static String azureTenant = "e37d725c-ab5c-4624-9ae5-f0533e486437";
  static String azureRedirectURL = "http://localhost/auth";
  final simpleAuth.AzureADApi azureApi = new simpleAuth.AzureADApi(
      "azure",
      azureClientId,
      "https://login.microsoftonline.com/$azureTenant/oauth2/authorize",
      "https://login.microsoftonline.com/$azureTenant/oauth2/token",
      "https://management.azure.com/",
      azureRedirectURL);
 
  void showError(dynamic ex) {
    showMessage(ex.toString());
  }

  void showMessage(String text) {
    var alert = new AlertDialog(content: new Text(text), actions: <Widget>[
      new FlatButton(
          child: const Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          })
    ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  void login(simpleAuth.AuthenticatedApi api) async {
    try {
      var success = await api.authenticate();
      showMessage("Logged in success: $success");
    } catch (e) {
      showError(e);
    }
  }

  void logout(simpleAuth.AuthenticatedApi api) async {
    await api.logOut();
    showMessage("Logged out");
  }


  Widget loginBuilder() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: SingleChildScrollView(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
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
            Container(
              child: new GradientButton(
                onPressed: () {
                  login(azureApi);
                },
                text: "Login with Uni Email"
                ),
            ),
            new Container()
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
            color: Colors.white, elevation: 2.0, child: loginBuilder()),
      ),
    );
  }

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    //loginBloc = new LoginBloc();
    //apiStreamSubscription = apiSubscription(loginBloc.apiResult, context);
    SimpleAuthFlutter.init(context);
    controller = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 1500));
    animation = new Tween(begin: 0.0, end: 1.0).animate(
        new CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn));
    animation.addListener(() => this.setState(() {}));
    controller.forward();
  }

  @override
  void dispose() {
    controller?.dispose();
    //loginBloc?.dispose();
    //apiStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return loginCard();
  }
}
