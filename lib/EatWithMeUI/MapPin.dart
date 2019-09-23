import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

class MapPin extends StatefulWidget {
  const MapPin({
    Key key,
    this.name : "No Name",
    this.pictureURL: 'images/TempProfile.png',
    this.onExpand,
    this.onCollapse,
    this.onOpenTapped,
  }) : super (key: key);

  final Function onExpand;
  final Function onCollapse;
  final Function onOpenTapped;
  final String pictureURL;
  final String name;

  _MapPinState createState() => _MapPinState();
}

class _MapPinState extends State<MapPin> {

  double width = 200;
  bool isOpen = false;

  @override 
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: width,
        maxHeight: width/3 + width/12),

      child: GestureDetector(
        onTapUp: (tapInfo) {

          var localTouchPosition = (context.findRenderObject() as RenderBox).globalToLocal(tapInfo.globalPosition);
          var middleTouched = localTouchPosition.dx > width/3 && localTouchPosition.dx < width*2/3;

          if(!isOpen)
          {
            if (middleTouched)
            {
              setState(()
              {
                isOpen = !isOpen;
              }); 
            }
          }
          else
          {
            setState(()
            {
              isOpen = !isOpen;
            });
          }     
        },
        child: Stack(
          children: <Widget>[   

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                alignment: Alignment.bottomCenter,
                constraints: BoxConstraints(maxHeight: width/20, maxWidth: width/10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width),
                  boxShadow : [BoxShadow(blurRadius: 10, color: Color.fromRGBO(0, 0, 0, 0.3))]
                ),
              ),
            ),
            

            FlareActor('animations/map-pin.flr',
              animation: isOpen ? "Open" : "Close"
            ),

            Align(
              alignment: Alignment.topRight,
              child: Container(
                alignment: Alignment.centerLeft,
                constraints: BoxConstraints(maxWidth: width*2/3, maxHeight: width/3),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(widget.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: isOpen ? Color(0xFF333333) : Colors.transparent,
                    ),
                  ),
                ),
              )
            ),
          ],
        )
      )  
    );
  }
}