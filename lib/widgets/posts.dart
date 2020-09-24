import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_chat/model/user.dart';
import 'package:social_chat/pages/home.dart';
import 'package:social_chat/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  Post(
      {this.postId,
      this.ownerId,
      this.username,
      this.location,
      this.description,
      this.mediaUrl,
      this.likes});

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc.data()["postId"],
      ownerId: doc.data()['ownerId'],
      username: doc.data()['username'],
      location: doc.data()['location'],
      description: doc.data()['description'],
      mediaUrl: doc.data()['medialUrl'],
      likes: doc.data()['likes'],
    );
  }

  int getLikeCounts(likes) {
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      ownerId: this.ownerId,
      username: this.username,
      location: this.location,
      description: this.description,
      mediaUrl: this.mediaUrl,
      likes: this.likes,
      postCount: getLikeCounts(this.likes));
}

class _PostState extends State<Post> {
  final String currentUserId = currentUSer?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  Map likes;
  int postCount;
  bool isLiked = false;
  bool showHeart = false;

  _PostState(
      {this.postId,
      this.ownerId,
      this.username,
      this.location,
      this.description,
      this.mediaUrl,
      this.likes,
      this.postCount});

  likePost() {
    bool _isLiked = likes[currentUserId] == true;
    if (_isLiked) {
      postsRef
          .doc(ownerId)
          .collection("usersPosts")
          .doc(postId)
          .update({'likes.$currentUserId': false});
      setState(() {
        postCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .doc(ownerId)
          .collection("usersPosts")
          .doc(postId)
          .update({'likes.$currentUserId': true});
      setState(() {
        postCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  buildPostHeader() {
    return FutureBuilder(
        future: userRef.doc(ownerId).get(),
        builder: (context, snapShot) {
          if (!snapShot.hasData) {
            return circleProgress();
          }
          User user = User.fromDocument(snapShot.data);
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    user.photoUrl,
                  ),
                  backgroundColor: Colors.grey,
                ),
                title: Text(
                  user.username,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(location),
                trailing: IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ),
              Container(
                child: Text(description),
              )
            ],
          );
        });
  }

  buildPostImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () => likePost(),
          child: CachedNetworkImage(
            imageUrl: mediaUrl,
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height / 1.65,
            width: MediaQuery.of(context).size.width,
          ),
        ),
        showHeart
            ? Animator(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                tween: Tween(begin: .8, end: 1.4),
                cycles: 0,
                builder: (context, anim, child) => Transform.scale(
                  scale: anim.value,
                  child: Icon(
                    Icons.favorite,
                    size: 120.0,
                    color: Colors.red[700],
                  ),
                ),
              ): Text(""),
      ],
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0, top: 20.0),
              child: Text(
                "$postCount likes",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Divider(),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Expanded(
                  child: Container(
                child: GestureDetector(
                    onTap: likePost,
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Row(
                        children: <Widget>[
                          isLiked
                              ? Icon(
                                  Icons.favorite,
                                  size: 28.0,
                                  color: Colors.red[700],
                                )
                              : Icon(
                                  Icons.favorite_border,
                                  size: 28.0,
                                ),
                          Padding(
                              padding: EdgeInsets.only(left: 5.0),
                              child: Text("Like")),
                        ],
                      ),
                    )),
              )),
              new Expanded(
                  child: Container(
                child: GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.comment,
                          size: 28.0,
                          color: Colors.black,
                        ),
                        new Padding(
                          padding: EdgeInsets.only(left: 5.0),
                          child: Text("Comment"),
                        )
                      ],
                    )),
              )),
              new Expanded(
                  child: Container(
                child: GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.share,
                          size: 28.0,
                          color: Colors.black,
                        ),
                        new Padding(
                          padding: EdgeInsets.only(left: 5.0),
                          child: Text("Share"),
                        )
                      ],
                    )),
              )),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          buildPostHeader(),
          buildPostImage(),
          buildPostFooter(),
        ],
      ),
    );
  }
}
