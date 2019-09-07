import 'package:eatwithme/models/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InterestList extends StatefulWidget {
  final ValueChanged<String> addInterest;
  final ValueChanged<String> removeInterest;

  const InterestList(
      {Key key, @required this.addInterest, @required this.removeInterest})
      : super(key: key);

  @override
  _InterestListState createState() => _InterestListState();
}

class _InterestListState extends State<InterestList> {
  @override
  Widget build(BuildContext context) {
    var interests = Provider.of<Iterable<Interest>>(context);
    return Expanded(
        child: GridView.builder(
            itemCount: interests.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (BuildContext context, int index) {
              return InterestButton(
                interest: interests.elementAt(index),
                addInterest: widget.addInterest,
                removeInterest: widget.removeInterest,
              );
            }));
  }
}

class InterestButton extends StatefulWidget {
  final Interest interest;
  final ValueChanged<String> addInterest;
  final ValueChanged<String> removeInterest;

  const InterestButton(
      {Key key,
      @required this.interest,
      @required this.addInterest,
      @required this.removeInterest})
      : super(key: key);

  @override
  _InterestButtonState createState() => _InterestButtonState();
}

class _InterestButtonState extends State<InterestButton> {
  bool _isPressed = false;

  // TODO: Replace colours with animation to show state
  Color _colour;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(widget.interest.name),
      color: _colour,
      onPressed: () {
        setState(() {
          _isPressed = !_isPressed;
          _colour = (_isPressed) ? Colors.orange : Colors.white;

          String id = widget.interest.id;

          _isPressed ? widget.addInterest(id) : widget.removeInterest(id);
        });
      },
    );
  }
}
