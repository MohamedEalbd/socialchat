import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_chat/model/user.dart';
import 'package:social_chat/pages/activity_feed.dart';
import 'package:social_chat/pages/profile.dart';
import 'package:social_chat/pages/search.dart';
import 'package:social_chat/pages/timeline.dart';
import 'package:social_chat/pages/upload.dart';

import 'create_user.dart';

final googleSignIn = GoogleSignIn();
final userRef = FirebaseFirestore.instance.collection("users");
final postsRef = FirebaseFirestore.instance.collection("posts");
final commentsRef = FirebaseFirestore.instance.collection("comments");
final feedRef = FirebaseFirestore.instance.collection("feed");
final followersRef = FirebaseFirestore.instance.collection("followers");
final followingRef = FirebaseFirestore.instance.collection("following");
final StorageReference storageReference = FirebaseStorage.instance.ref();
final DateTime timestamp = DateTime.now();

User currentUSer;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController = PageController();
  int pageIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print("error is $err");
    });
    try {
      googleSignIn.signInSilently(suppressErrors: false).then((account) {
        handleSignIn(account);
      }).catchError((onError) {
        print("error in reopen $onError");
      });
    } catch (e) {
      print("signInSilently${e.toString()}");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFireStore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFireStore() async {
    String username = '';
    //************** get current user
    final GoogleSignInAccount user = googleSignIn.currentUser;
    //************* check user exists in table users id
     DocumentSnapshot doc = await userRef.doc(user.id).get();
    if (!doc.exists) {
      //************* if not exists create page for add username
      username = await Navigator.push(
          context, MaterialPageRoute(builder: (_) => CreateUser()));
      //****** insert data in table user
      userRef.doc(user.id).set({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp
      });
       doc = await userRef.doc(user.id).get();
    }
      currentUSer = User.fromDocument(doc);
     print(currentUSer);
     print(currentUSer.displayName);
    //  print("xxxx$currentUSer.displayName");
     print(username);
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
        pageIndex, duration: Duration(milliseconds: 200),
        curve: Curves.bounceInOut);
  }

  Widget buildAuthScreen() {
    //home page at authentication
    return Scaffold(
      body: PageView(
        children: <Widget>[
          RaisedButton(
            onPressed: () => logout(),
            child: Text("LogOut"),),
          //  TimeLine(),
          ActivityFeed(),
          Upload(currentUser:currentUSer),
          Search(),
          Profile(
            profileId: currentUSer?.id,
          ),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        activeColor: Theme
            .of(context)
            .primaryColor,
        onTap: onTap,
        currentIndex: pageIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
          ),
        ],
      ),
    );
  }

  Widget buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        color: Theme
            .of(context)
            .primaryColor,
        child: Column(
          children: [
            Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.only(top: 70, left: 20, bottom: 30),
              child: Column(
                children: [
                  Text("Login"),
                  Text("Welcome to Social Chat"),
                ],
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(60),
                        topLeft: Radius.circular(60))),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => login(),
                        child: Container(
                          margin: EdgeInsets.only(top: 10),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          child: Text(
                            "Sign in By Google",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
