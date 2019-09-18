import 'package:flutter/material.dart';

ThemeData themeLight() {
  return ThemeData(
    primaryColor: Colors.orange,
    backgroundColor: Colors.white,
    canvasColor: Colors.transparent,
    fontFamily: 'Roboto',
  );
}

//Colours
class ThemeColours {
  static List<Color> kitGradients = [
    Colors.orange.shade800,
    Colors.orange.shade400,
  ];
}
// new Color.fromRGBO(103, 218, 255, 1.0),
    // new Color.fromRGBO(3, 169, 244, 1.0),
    // new Color.fromRGBO(0, 122, 193, 1.0),
    //Colors.orange.shade800,
    //Colors.white,