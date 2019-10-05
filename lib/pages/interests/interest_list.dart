import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/widgets/loadingCircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InterestList extends StatefulWidget {
  final ValueChanged<Interest> addInterest;
  final ValueChanged<Interest> removeInterest;

  const InterestList(
      {Key key, @required this.addInterest, @required this.removeInterest})
      : super(key: key);

  @override
  _InterestListState createState() => _InterestListState();
}

class _InterestListState extends State<InterestList> {
  @override
  Widget build(BuildContext context) {
    var dbInterests = Provider.of<Iterable<Interest>>(context);
    var userInterests = Provider.of<Set<Interest>>(context);
    
    if (dbInterests == null || userInterests == null) {
      return Expanded(child: LoadingCircle(),);
    }
    
    return Expanded(
        child: GridView.builder(
            itemCount: dbInterests.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (BuildContext context, int index) {
              var interest = dbInterests.elementAt(index);

              if (interest == null) return LoadingCircle();

              return InterestButton(
                interest: interest,
                isInitiallyOn: userInterests.contains(interest),
                addInterest: widget.addInterest,
                removeInterest: widget.removeInterest,
              );
            }));
  }
}

class InterestButton extends StatefulWidget {
  final Interest interest;
  final ValueChanged<Interest> addInterest;
  final ValueChanged<Interest> removeInterest;
  final bool isInitiallyOn;

  const InterestButton(
      {Key key,
      @required this.interest,
      @required this.isInitiallyOn,
      @required this.addInterest,
      @required this.removeInterest,})
      : super(key: key);

  @override
  _InterestButtonState createState() => _InterestButtonState();
}

class _InterestButtonState extends State<InterestButton> {
  bool _isPressed;

  // TODO: Replace colours with animation to show state
  Color _colour;

  void _updateColour() {
    setState(() {
      _colour = (_isPressed) ? Colors.orange : Colors.white;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _isPressed = widget.isInitiallyOn;
      _updateColour();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(widget.interest.name),
      color: _colour,
      onPressed: () {
        setState(() {
          _isPressed = !_isPressed;
          _updateColour();

          _isPressed ? widget.addInterest(widget.interest) : widget.removeInterest(widget.interest);
        });
      },
    );
  }
}
