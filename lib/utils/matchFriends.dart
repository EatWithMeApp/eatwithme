import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Friends extends StatefulWidget {
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  Future getUsers() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("Users").getDocuments();
    return qn.documents;
  }
  List a ;
  List myInt = ["Eating","drinking"];
  List uers = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          child: FutureBuilder(
              future: getUsers(),
              builder: (_, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting){
                  return Center(
                    child: Text ("Loading..."),
                  );
                }else{
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (_, index){
                        if (index == 0){
                          a = [];
                        }
                        a = snapshot.data[index].data["interests"];
                        for (String interest in myInt){
                          if (a.contains(interest)){
                            uers.add(snapshot.data[index].data);
                          }
                        }


                        if (index == snapshot.data.length-1){
                          return Text(uers.toString());

                        }else{
                          return Text(" ");
                        }

                      }

                      );
                  }
              }
              ),
        )
    );
  }
}
