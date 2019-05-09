import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' show radians;

class AnimationButton extends StatefulWidget{
  @override
  ButtonState createState() => ButtonState();
}

class ButtonState extends State<AnimationButton> with TickerProviderStateMixin{
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
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
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
        child: AnimatedIcon(
          icon: AnimatedIcons.home_menu,
          progress: _animateIcon,
        ),
      ),
    );
  }

  _buildButton(double angle, {Color color, IconData icon}) {
      final double rad = radians(angle);
      return Transform(
        transform: Matrix4.identity()..translate(
          (_translateButton.value) * cos(rad), 
          (_translateButton.value) * sin(rad)
        ),
        child: FloatingActionButton(
          child: Icon(icon), 
          backgroundColor: color, 
          onPressed: (){}, 
          elevation: 0
          )
      );
    }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        _buildButton(-90, color: Colors.black),
        _buildButton(0, color: Colors.red),
        _buildButton(-45, color: Colors.orange),
        toggle(),
      ],
    );
  }

}