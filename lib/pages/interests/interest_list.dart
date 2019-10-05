import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/widgets/loadingCircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eatwithme/EatWithMeUI/InterestButton.dart';

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
        child: Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), 
                topRight: Radius.circular(30)
                ),
              color: Colors.white,
              
            ),
            child: GridView.builder(
              itemCount: dbInterests.length,
              padding: EdgeInsets.all(5),
              gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (BuildContext context, int index) {
                var interest = dbInterests.elementAt(index);

                if (interest == null) return LoadingCircle();

                return Padding(
                  padding: EdgeInsets.all(8),
                  child: InterestButton(
                    interest: interest,
                    initiallyOn: userInterests.contains(interest),
                    addInterest: widget.addInterest,
                    removeInterest: widget.removeInterest,
                  )
                );           
              })
            )
          )
        );       
  }
}
