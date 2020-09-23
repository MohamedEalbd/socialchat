import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_chat/widgets/header.dart';
import 'package:social_chat/widgets/progress.dart';

final userRef = FirebaseFirestore.instance.collection("users");

class TimeLine extends StatefulWidget {
  @override
  _TimeLineState createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {
  List<dynamic> users = [];
  // how i can make create ,update and delete from firebase
  // createUser(){
  //   userRef.doc("2547").set({
  //     'name':'mohamed',
  //     'isAdmin' : false,
  //     'postsCount' : 1
  //   });
  // }
  // updateUser() async{
  //  final DocumentSnapshot docs = await userRef.doc("2547").get();
  //  if(docs.exists){
  //    docs.reference.update({
  //      'name':'Bebo',
  //      'isAdmin' : false,
  //      'postsCount' : 1
  //    });
  //  }
  // }
  // deleteUser() async{
  //   final DocumentSnapshot docs = await userRef.doc("2547").get();
  //   if(docs.exists) {
  //     docs.reference.delete();
  //   }
  // }
  // getUser() async {
  //   print("enter");
  //   QuerySnapshot snapshot = await userRef.get();
  //   setState(() {
  //     users = snapshot.docs;
  //   });
  //   // snapshot.docs.forEach((DocumentSnapshot doc) {
  //   //   print(doc.data());
  //   //   print(doc.id);
  //   //   print(doc.exists);
  //   // });
  // }
  // getUserById() async {
  //   final String id = "DigazsGY5GKPIudPR8q9";
  //   final DocumentSnapshot doc = await userRef.doc(id).get();
  //   print(doc.data());
  //   print(doc.id);
  //   print(doc.exists);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context, isAppTitle: true),
        body:  StreamBuilder<QuerySnapshot>(
             stream: userRef.snapshots() ,
            builder: (context,snapShot){
              if(!snapShot.hasData){
                return circleProgress();
              }
             // List<Text> child = snapShot.data.docs.map((user) => Text(user['name'])).toList();
              return ListView.builder(
                itemCount: snapShot.data.docs.length,
                itemBuilder: (context,i){
                  return Text(snapShot.data.docs[i].get('name'));
                },
              );
            })
    );
  }
}
