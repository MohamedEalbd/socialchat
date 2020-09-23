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
    likes.forEach((val) {
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
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;
  int postCount;

  _PostState(
      {this.postId,
      this.ownerId,
      this.username,
      this.location,
      this.description,
      this.mediaUrl,
      this.likes,
      this.postCount});

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
    return GestureDetector(
      onTap: () {},
      child: CachedNetworkImage(
        imageUrl: mediaUrl,
        fit: BoxFit.cover,
        height: MediaQuery.of(context).size.height / 1.65,
        width: MediaQuery.of(context).size.width,
      ),
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
                        onTap: () {
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.favorite,
                                size: 28.0,
                                color: Colors.pink,
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
                        onTap: () {
                        },
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
