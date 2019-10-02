import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:flutter/material.dart';

class MapLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
          gradient: new LinearGradient(
        colors: ThemeColours.kitGradients,
      )),
      child: Center(
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ListTile(
                leading: CircularProgressIndicator(),
                title: Text("We're loading the map for you, sit tight!"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
