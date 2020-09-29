import 'package:flutter/material.dart';
import 'package:social_chat/pages/home.dart';
import 'package:social_chat/widgets/header.dart';
import 'package:social_chat/widgets/posts.dart';
import 'package:social_chat/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String postId;
  final String userId;

  PostScreen({this.postId, this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: postsRef.doc(userId).collection("usersPosts").doc(postId).get(),
        builder: (context, snapShot) {
          if(!snapShot.hasData){
            return circleProgress();
          }
          if(snapShot.data != null){
            Post post = Post.fromDocument(snapShot.data);
            return Scaffold(
              appBar: header(context,name: post.description),
              body: ListView(
                children: [
                  Container(
                    child: post,
                  )
                ],
              ),
            );
          }
           return Container();
        });
  }
}
