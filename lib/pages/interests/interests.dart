import 'package:flutter/material.dart';
import 'package:eatwithme/pages/profile/profile.dart';

class Interests extends StatefulWidget
{
  @override
  State<StatefulWidget> createState()
  {
    return _InterestsState();
  }
}

class _InterestsState extends State<Interests>
{
  List<String> interestsList = ['movies', 'science', 'psychology', 'computer science', 'engineering', 'sociology'];
  List<String> userInterests = [];
  String currentInterest = 'movies';
  @override
  Widget build(BuildContext context)
  {
    return Scaffold                                               //Holds all the Widgets
    (
      appBar: AppBar                                              //Top little bar on the app
      (
        title: Text('Interests'),
        backgroundColor: Colors.deepOrangeAccent,
      ),

      body: Container
      (
        child: Column
        (
          children: <Widget>
          [
            ////////TEXT OBJECT//////
            Text
            (
              'Select Your Interests',
              style: TextStyle(fontSize: 50.0),
              textAlign: TextAlign.center,
            ),
            //////TEXT OBJECT///////
            ///
            ///TEXT OBJECT 2/////////
            Text
            (
              'Up to 5',
              style: TextStyle(fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            ///TEXT OBJECT 2/////////
            ///
            ////////DROPDOWN BOX///////////
            new DropdownButton<String>
            (
              value: currentInterest,
              onChanged: (String newValue)
              {
                onDropdownChanged(newValue);
              },
              items: interestsList.map
              (
                (String value)
                {
                  return new DropdownMenuItem<String>
                  (
                    child: Text(value),
                    value: value,
                  );
                }
              ).toList()
            ),
            ////////DROPDOWN BOX///////////
            ///
            ///BUTTON/////////////////////
            new RaisedButton
            (
              child: Text("Add Interest"),
              elevation: 5.0,
              color: Colors.deepOrange,
              onPressed: ()
              {
                addInterest();
              },
            ),
            ///BUTTON////////////////////
            ///
            ///LIST OF INTERESTS////////
            Expanded
            (
              child: new ListView.builder
              (
                itemCount: userInterests.length,
                itemBuilder: (BuildContext context, int index)
                {
                  return new Dismissible
                  (
                    key: new Key(userInterests[index]),
                    onDismissed: (direction)
                    {
                      userInterests.removeAt(index);
                    },
                  child: new ListTile
                  (
                    title: new Text("${userInterests[index]}"),
                  )
                  );
                },
              )
            ),
            ///LIST OF INTERESTS////////
            RaisedButton
            (
              child: Text('SAVE'),
              elevation: 5.0,
              color: Colors.deepOrange,
              onPressed: ()
              {
                submitInterests();
              },
            ),
          ],
        ),
      )
    );
  }
  onDropdownChanged(String newValue)
  {
    setState
    (
      ()
      {
        currentInterest = newValue; 
      }
    );
  }

  addInterest()
  {
    if(userInterests.length < 5)
    {
      userInterests.add(currentInterest);
    }
  }

  submitInterests()
  {
    //TODO save the userIntersts list to firebase
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
  }
}
    