import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:eatwithme/models/models.dart';

class InterestButton extends StatefulWidget{
  const InterestButton({
    Key key,
    this.interest,
    this.initiallyOn = false,
    this.addInterest,
    this.removeInterest,
  }) : super(key: key);
  
  final Interest interest;
  final bool initiallyOn;
  final Function addInterest;
  final Function removeInterest;

  _InterestButtonState createState() => _InterestButtonState();
}

class _InterestButtonState extends State<InterestButton> {

  bool isOn;
  bool clicked = false;
  double size = 160;
  Color textColour;

  @override
  void initState() {
    isOn = !widget.initiallyOn;
    if (!isOn)
    {
      textColour = Colors.white;
    }
    else
    {
      textColour = Color(0xff333333);
    }
    super.initState();
  }
  
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
            if(clicked)
            {
              if (!isOn)
              {
                textColour = Colors.white;
                widget.addInterest(widget.interest);        
              }
              else{
                textColour = Color(0xff333333);
                widget.removeInterest(widget.interest);
              }
              isOn = !isOn;
            }
            else{
              if (isOn)
              {
                textColour = Colors.white;
                widget.addInterest(widget.interest);        
              }
              else{
                textColour = Color(0xff333333);
                widget.removeInterest(widget.interest);
              }
            }
            clicked = true;
          });
        },
        child:Stack( 
          children : <Widget> [         
            FlareActor("animations/interest-button.flr",
                animation: isOn ? "ToggleOn" : "ToggleOff",
                //snapToEnd: !clicked,
                isPaused: !clicked,
                ),
            Align(
              alignment: Alignment.center,
              child: Text(
                widget.interest.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                   color: textColour,
                   fontSize: 18,
                   fontWeight: FontWeight.w400
                 ),
              ),
            ),    
          ]
        )
      )
    );
  }
}