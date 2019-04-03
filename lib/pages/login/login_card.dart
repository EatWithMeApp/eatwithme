//Adapted from https://github.com/iampawan/Flutter-UI-Kit/blob/master/lib/ui/page/login/login_one/login_card.dart

import 'package:flutter/material.dart';
import 'package:eatwithme/widgets/gradient_button.dart';

class LoginCard extends StatefulWidget {
  @override
  _LoginCardState createState() => new _LoginCardState();
}

class _LoginCardState extends State<LoginCard>
    with SingleTickerProviderStateMixin {
  
  var deviceSize;
  Animation<double> animation;
  AnimationController controller;

  Widget loginBuilder() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: SingleChildScrollView(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new TextField(
              //onChanged: (phone) => phoneNumber = phone,
              //enabled: !snapshot.data,
              style: new TextStyle(fontSize: 15.0, color: Colors.black),
              decoration: new InputDecoration(
                  hintText: "",
                  labelText: "Username",
                  labelStyle: TextStyle(fontWeight: FontWeight.w700)),
            ),
            new SizedBox(
              height: 10.0,
            ),
            new TextField(
              //onChanged: (myotp) => otp = myotp,
              //keyboardType: TextInputType.number,
              style: new TextStyle(fontSize: 15.0, color: Colors.black),
              decoration: new InputDecoration(
                  hintText: "",
                  labelText: "Password",
                  labelStyle: TextStyle(fontWeight: FontWeight.w700)),
              obscureText: true,
            ),
            new SizedBox(
              height: 30.0,
            ),
            Container(
              child: new GradientButton(text: "Login"),
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
