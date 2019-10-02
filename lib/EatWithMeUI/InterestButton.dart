import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

class InterestButton extends StatefulWidget{
  const InterestButton({
    Key key,
    this.text = "Error"
  }) : super(key: key);
  
  final String text;

  _InterestButtonState createState() => _InterestButtonState();
}

class _InterestButtonState extends State<InterestButton> {

  bool isOn = false;
  bool tapped = false;
  double size = 160;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: size,
        maxHeight: size
      ),
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(blurRadius: 4, offset: Offset(0, 2), color: Color.fromRGBO(0, 0, 0, 0.3))], 
        borderRadius: BorderRadius.circular(size/8),
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            tapped = true;
            isOn = !isOn;
          });
        },
        child:Stack( 
          children : <Widget> [         
            FlareActor("animations/interest-button.flr",
                animation: tapped&&isOn? "ToggleOn" : tapped?"ToggleOff":null ,
                ),
            Align(
              alignment: Alignment.center,
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                // style: TextStyle(
                //   color: Color(0x333333)
                // ),
              ),
            ),    
          ]
        )
      )
    );
  }
}