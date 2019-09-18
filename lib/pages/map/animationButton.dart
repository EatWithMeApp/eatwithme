import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' show radians;

class AnimationButton extends StatefulWidget {   
  final VoidCallback button1;
  final VoidCallback button2;
  final VoidCallback button3;

  const AnimationButton({Key key, this.button1, this.button2, this.button3}) : super(key: key);

  @override
  ButtonState createState() => ButtonState();
}

class ButtonState extends State<AnimationButton> with TickerProviderStateMixin {
  bool isOpened = false;
  double _fabHeight = 56.0;
  Animation<double> _translateButton;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Curve _curve = Curves.easeOut;

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: 80,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.5,
        0.75,
        curve: _curve,
      ),
    ));
        
    // widget.button1 = VoidCallback(_translateButton, 225, color: Colors.orange);
    // widget.button2 = VoidCallback(_translateButton, 180, color: Colors.red);
    // widget.button3 = VoidCallback(_translateButton, -90, color: Colors.black);

    animate();

    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: animate,
        tooltip: 'Toggle',
        // child: AnimatedIcon(
        //   icon: AnimatedIcons.home_menu,
        //   progress: _animateIcon,
        // ),
        //TODO: Animate EatWithMeGuy when clicked
        child: Hero(
            tag: 'EatWithMeLogin',
            child: Image.asset(
              'images/EatWithMeGuy.png',
              width: 45.0,
            )),
      ),
    );
  }

  // _buildButton(double angle, {Color color, IconData icon}) {
  //   final double rad = radians(angle);
  //   return Transform(
  //       transform: Matrix4.identity()
  //         ..translate((_translateButton.value) * cos(rad),
  //             (_translateButton.value) * sin(rad)),
  //       child: FloatingActionButton(
  //           child: Icon(icon),
  //           backgroundColor: color,
  //           onPressed: () {},
  //           elevation: 0));
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: Stack(
        // fit: StackFit.passthrough,
        // overflow: Overflow.visible,
        alignment: AlignmentDirectional.bottomEnd,
        children: <Widget>[
          FancyButton(_translateButton, -90, Colors.black, Icons.account_circle, widget.button3,),
          //FancyButton(_translateButton, 180, color: Colors.red),
          //FancyButton(_translateButton, 225, color: Colors.orange),
          toggle(),
        ],
      ),
    );
  }
}

abstract class UseFunction {
  void onClick();
}

class FancyButton extends StatelessWidget {
  final Animation<double> translateButton;
  final double angle;
  final Color color;
  final IconData icon;
  
  final VoidCallback onClick;

  FancyButton(this.translateButton, this.angle, this.color, this.icon, this.onClick);
  
  @override
  Widget build(BuildContext context) {
    final double rad = radians(angle);
    return Transform(
        transform: Matrix4.identity()
          ..translate((translateButton.value) * cos(rad),
              (translateButton.value) * sin(rad)),
        child: FloatingActionButton(
            child: Icon(icon),
            backgroundColor: color,
            onPressed: () => onClick,
            // onPressed: () {print('FAB clicked');},
            elevation: 7.0));
  }

}