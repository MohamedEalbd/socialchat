import 'dart:async';

import 'package:flutter/material.dart';
import 'package:social_chat/widgets/header.dart';
class CreateUser extends StatefulWidget {
  @override
  _CreateUserState createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
   String username = '';
   final key = GlobalKey<FormState>();
   final scaffoldKey = GlobalKey<ScaffoldState>();
   submitData(){
     print("www");
  final form = key.currentState;
  if(form.validate()) {
    form.save();
    SnackBar snackBar = SnackBar(content: (Text("Welcome to chat ")));
    scaffoldKey.currentState.showSnackBar(snackBar);
    Timer(Duration(seconds: 2), (){
     setState(() {
       Navigator.pop(context,username);
     });
    });
  }
   }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: header(context,name: "Create User",removeBackButton: true),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom:15.0),
                  child: Text("Create User Name",style: TextStyle(fontSize: 25.0),),
                ),
                Container(
                  child: Form(
                    key: key,
                    autovalidate: true,
                    child: Column(
                      children: [
                        TextFormField(
                          validator: (val){
                            if(val.trim().length<3||val.isEmpty){
                              return "user name too short";
                            }else if(val.trim().length>12){
                              return "user name too long";
                            }else{
                              return null;
                            }
                          },
                          onSaved: (val) => username = val ,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top:0,bottom: 0,left: 10),
                            border: OutlineInputBorder(),
                            labelText: "UserName",
                            hintText: "Must be at 3 char"
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top:20.0),
                          child: MaterialButton(
                            color: Theme.of(context).primaryColor,
                            minWidth: 300.0,
                            onPressed: (){
                            submitData();
                          },child: Text("Submit",style: TextStyle(color: Colors.white),),),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
