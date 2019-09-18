//Adapted from https://github.com/iampawan/Flutter-UI-Kit/blob/master/lib/ui/widgets/gradient_button.dart

import 'package:flutter/material.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';

class GradientButton extends StatelessWidget {
  final GestureTapCallback onPressed;
  final String text;
  final Key key;

  GradientButton({@required this.onPressed, @required this.text, this.key});
  //GradientButton({@required this.text});

  @override
  Widget build(BuildContext context) {
    return Material(
      key: key,
      elevation: 0.0,
      color: Colors.transparent,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onPressed,
        splashColor: Colors.orange,
        child: Ink(
          height: 50.0,
          decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              gradient: LinearGradient(
                colors: ThemeColours.kitGradients,
              )),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 20.0,
                  letterSpacing: 1.0),
            ),
          ),
        ),
      ),
    );
  }
}