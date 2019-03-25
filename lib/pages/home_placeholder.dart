import 'package:flutter/material.dart';

class EatWithMeHomePlaceholder extends StatefulWidget {
  @override
  EatWithMeHomeState createState() => new EatWithMeHomeState();
}

class EatWithMeHomeState extends State<EatWithMeHomePlaceholder> {
  @override
  Widget build(BuildContext context) {
    final _menuButton = new IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
    );
    return Scaffold(
        appBar: AppBar(
          title: Text('Eat With Me - Home'),
          centerTitle: true,
          leading: Builder(
            builder: (BuildContext context) {
              return _menuButton;
            },
          ),
        ),
        body: _buildHomePlaceholder());
  }
}

Widget _buildHomePlaceholder() {
    
}