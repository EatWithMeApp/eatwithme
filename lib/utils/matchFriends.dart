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
  List a;

  navigateToDetail(DocumentSnapshot user){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> DetailPage(user: user,)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    if (snapshot.data[index].data["interests"].contains("eating")){
                      return ListTile(
                        title: Text(snapshot.data[index].data["interests"].toString()),
                        onTap: () => navigateToDetail(snapshot.data[index]),

                      );
                    }
                  });
            }
          }),
    );
  }
}

class DetailPage extends StatefulWidget {

  final DocumentSnapshot user;

  DetailPage({this.user});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child:Card(
          child: ListTile(
            title: Text(widget.user.data.toString()),

          ),
        )
    );
  }
}
