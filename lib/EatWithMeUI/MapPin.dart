import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';



class MyPainter extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    var paint = Paint();
    paint.color = Color(0xFFFF7922);
    var path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width/2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
  

}
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
    
      return AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOutBack,
        alignment: Alignment.center,
        constraints: BoxConstraints(
          maxWidth: isOpen ? width : width/3,
          maxHeight: width/3 + width/12),

        child: GestureDetector(
          onTapUp: (tapInfo) {
            if(!isOpen)
            {
              setState(()
              {
                isOpen = !isOpen;
              });         
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

              Container(
                padding: EdgeInsets.only(bottom: width/60),
                alignment: Alignment.bottomCenter,
                child: CustomPaint(
                  size: Size(width/15, width/10),
                  painter: MyPainter(),
                ),
              ),

              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(width/50),
                  constraints: BoxConstraints(maxHeight: width/3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width),
                    color: Color(0xFFFF7922),
                  ),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width),
                      color: Color(0xFFEAEAEA),
                    ),
                  )
                ),
              ),

              Container(
   
                padding: EdgeInsets.only(right: width/6),
                alignment: Alignment.topRight,
                child: AnimatedOpacity(
                  opacity: isOpen ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 350),
                child: Container(
                  //decoration: BoxDecoration(color: Colors.blue),
                  alignment: Alignment.centerLeft,
                  constraints: BoxConstraints(maxWidth: width/2, maxHeight: width/3),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(widget.name,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                )
                )
              ),
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.all(width/50),
                child: Container(
                  alignment: Alignment.center,
                  constraints: BoxConstraints(maxHeight: width/3 - width/25, maxWidth: width/3 - width/25),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width),
                    color: Colors.white,
                    boxShadow: [BoxShadow(blurRadius: 4, color: Color.fromRGBO(0, 0, 0, 0.3))]
                  ),
                ),
              ),
              
              
              //FlareActor('animations/map-pin.flr',
              //   animation: isOpen ? "Open" : "Close"
              // ),
            ],
          )
        )  
    );
  }
}