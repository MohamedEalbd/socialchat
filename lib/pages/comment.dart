import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_chat/pages/home.dart';
import 'package:social_chat/widgets/header.dart';
import 'package:social_chat/widgets/progress.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String mediaUrl;

  Comments({this.postId, this.ownerId, this.mediaUrl});

  @override
  _CommentsState createState() => _CommentsState(
      postId: this.postId, ownerId: this.ownerId, mediaUrl: this.mediaUrl);
}

class _CommentsState extends State<Comments> {
  final String postId;
  final String ownerId;
  final String mediaUrl;

  _CommentsState({this.postId, this.ownerId, this.mediaUrl});

  TextEditingController _commentController = TextEditingController();

  addComment() {
    commentsRef.doc(postId).collection("comments").add({
      'username': currentUSer.username,
      'comment': _commentController.text,
      'avatarUrl': currentUSer.photoUrl,
      'timestamp': timestamp,
      'userId': currentUSer.id,
    });
    feedRef.doc(ownerId).collection("feedItems").doc(postId).set({
      'type' : 'comment',
      'commentData' :_commentController.text,
      'username' : currentUSer.username,
      'userId' : currentUSer.id,
      'userProfileImg' : currentUSer.photoUrl,
      'postId' : postId,
      'mediaUrl' : mediaUrl,
      'timestamp' : timestamp,
    });
    _commentController.clear();

  }

  buildComment() {
    return StreamBuilder<QuerySnapshot>(
        stream: commentsRef.doc(postId).collection('comments').snapshots(),
        builder: (context, snapShot) {
          if (!snapShot.hasData) {
            return circleProgress();
          }
          List<Comment> comment = [];
          snapShot.data.docs.forEach((doc) {
            comment.add(Comment.fromDocument(doc));
          });
          return ListView.builder(
            itemCount: snapShot.data.docs.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                        snapShot.data.docs[index].data()['avatarUrl'],
                      ),
                    ),
                    title: Text(snapShot.data.docs[index].data()['comment']),
                    subtitle: Text(snapShot.data.docs[index].data()['timestamp'].toDate().toString()),
                    trailing: IconButton(icon: Icon(Icons.close_rounded), onPressed: (){
                      commentsRef.doc(postId).collection("comments").doc(snapShot.data.docs[index].id).delete();
                    }),
                  ),
                  Divider(),
                ],
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, name: "Comments"),
      body: Column(
        children: [
          Expanded(
            child: buildComment(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: _commentController,
              decoration: InputDecoration(labelText: "Write a comments"),
            ),
            trailing: OutlineButton(
              onPressed: () => addComment(),
              child: Text("Post"),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String id;
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comment(
      {this.id,
      this.username,
      this.userId,
      this.avatarUrl,
      this.comment,
      this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      id: doc.data()['id'],
      username: doc.data()['username'],
      userId: doc.data()['userId'],
      avatarUrl: doc.data()['avatarUrl'],
      comment: doc.data()['comment'],
      timestamp: doc.data()['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timestamp.toDate().toString()),
          trailing: IconButton(
            icon: Icon(Icons.close_sharp),
            onPressed: () {
              commentsRef
                  .doc('dd50f10d-2421-4db4-a5d1-19041f52d591')
                  .collection('comments')
                  .doc(userId)
                  .delete();
            },
          ),
        )
      ],
    );
  }
}
