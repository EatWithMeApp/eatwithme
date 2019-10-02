import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

class RadialMenu extends StatefulWidget {
  const RadialMenu({
    Key key,
    this.onChatTapped,
    this.onProfileTapped,
    this.onSettingsTapped,
    this.onMenuTapped,
    this.onCrossTapped,
  }) : super(key: key);

  final Function onChatTapped;
  final Function onProfileTapped;
  final Function onSettingsTapped;
  final Function onMenuTapped;
  final Function onCrossTapped;

  _RadialMenuState createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu> {

  bool isOpen = false;
  bool tapped = false;
  double size = 200;

  @override
  Widget build(BuildContext context) {
    return Container( 
      constraints: BoxConstraints(
        maxWidth: size,
        maxHeight: size),
        child: GestureDetector(
          onTapUp: (tapInfo) {
            var localTouchPosition = (context.findRenderObject() as RenderBox).globalToLocal(tapInfo.globalPosition);

            var topLeftTouched = localTouchPosition.dy < size/2 && localTouchPosition.dx < size/2;

            var topRightTouched = localTouchPosition.dy < size/2 && localTouchPosition.dx > size/2;

            var bottomLeftTouched = localTouchPosition.dy > size/2 && localTouchPosition.dx < size/2;

            var bottomRightTouched = localTouchPosition.dy > size/2 && localTouchPosition.dx > size/2;

            if (isOpen)
            {
              if (topLeftTouched)
              {
                print("Profile");
                widget.onProfileTapped();
              }
              else if (topRightTouched)
              {
                print("Chat");
                widget.onChatTapped();
              }
              else if (bottomLeftTouched)
              {
                print("Settings");
                widget.onSettingsTapped();
              }
              else if (bottomRightTouched)
              {
                widget.onCrossTapped();
                setState(()
                {
                  isOpen = !isOpen;
                }); 
              }
            }
            else
              if(bottomRightTouched)
              {
                widget.onMenuTapped();
                setState(()
                {
                  isOpen = !isOpen;
                }); 
              }

          },
          child: FlareActor("animations/menu.flr",
          animation: isOpen? "Open" : "Close",
          alignment: Alignment.bottomRight,
          
          ),
        )  
      );
  }
}