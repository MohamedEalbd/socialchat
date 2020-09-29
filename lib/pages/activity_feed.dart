import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_chat/pages/home.dart';
import 'package:social_chat/pages/post_screen.dart';
import 'package:social_chat/pages/profile.dart';
import 'package:social_chat/widgets/header.dart';
import 'package:social_chat/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getFeedData() async {
    QuerySnapshot snapshot = await feedRef
        .doc(currentUSer.id)
        .collection("feedItems")
        .orderBy("timestamp", descending: true)
        .limit(50)
        .get();
    List<ActivityFeedItem> activityItem = [];
    snapshot.docs.forEach((doc) {
      activityItem.add(ActivityFeedItem.fromDocument(doc));
    });
    return activityItem;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, name: "ActivityFeeds"),
      body: FutureBuilder(
        future: getFeedData(),
        builder: (context,snapShot){
          if(!snapShot.hasData){
            return circleProgress();
          }
          return ListView(
            children: snapShot.data,
          );
        },
      )
    );
  }
}

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type;
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;

  ActivityFeedItem({
    this.username,
    this.userId,
    this.type,
    this.mediaUrl,
    this.postId,
    this.userProfileImg,
    this.commentData,
    this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot docs) {
    return ActivityFeedItem(
      username: docs.data()['username'],
      userId: docs.data()['userId'],
      type: docs.data()['type'],
      mediaUrl: docs.data()['mediaUrl'],
      postId: docs.data()['postId'],
      userProfileImg: docs.data()['userProfileImg'],
      commentData: docs.data()['commentData'],
      timestamp: docs.data()['timestamp'],
    );
  }

  String activityItemText;
  Widget mediaPreview;

  configureMediaPreview(context) {
    if (type == 'like' || type == 'comment') {
      mediaPreview = InkWell(
        onTap: () => showPost(context),
        child: Container(
          height: 50,
          width: 50,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(mediaUrl),
                      fit: BoxFit.cover)),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text("");
    }
    if (type == 'like') {
      activityItemText = 'like your post';
    } else if (type == 'follow') {
      activityItemText = 'is follow you';
    } else if (type == 'comment') {
      activityItemText = 'replied : $commentData';
    } else {
      activityItemText = "Error : $type ";
    }
  }
showPost(context){
    Navigator.push(context, MaterialPageRoute(builder: (context) => PostScreen(postId: postId,userId: userId,)));
}
showProfile(context,{profileId}){
    Navigator.push(context, MaterialPageRoute(builder: (_)=> Profile(profileId: profileId,)));
}
  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Container(
      padding: EdgeInsets.only(bottom: 2.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(userProfileImg),
        ),
        title: GestureDetector(
          onTap: ()=>showProfile(context,profileId: userId),
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
                style: TextStyle(fontSize: 14.0, color: Colors.black),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  TextSpan(
                    text: " $activityItemText",
                  ),
                ]),
          ),
        ),
        subtitle: Text(
          timeago.format(timestamp.toDate()),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: mediaPreview,
      ),
    );
  }
}
