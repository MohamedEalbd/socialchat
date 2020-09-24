import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:social_chat/model/user.dart';
import 'package:social_chat/pages/edit_profile.dart';
import 'package:social_chat/pages/home.dart';
import 'package:social_chat/widgets/header.dart';
import 'package:social_chat/widgets/post_tile.dart';
import 'package:social_chat/widgets/posts.dart';
import 'package:social_chat/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUSer?.id; // iam put question mark to avoid if the return value == null skipped بحطها علشان لو القيمه فاضيه ميوقفش البرنامج
  String postView = "grid";
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfilePost();
  }

  BuildCount(String name, String count) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        Text(
          name,
          style: TextStyle(fontSize: 16.0, color: Colors.grey),
        )
      ],
    );
  }

  buildButton() {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: FlatButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditProfile(
                      currentUserId: currentUserId,
                    ))),
        child: Container(
          alignment: Alignment.center,
          width: 250,
          height: 30,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Edit Profile",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  buildProfileHeader() {
    return FutureBuilder(
        future: userRef.doc(widget.profileId).get(),
        builder: (context, snapShot) {
          if (!snapShot.hasData) {
            return circleProgress();
          }
          User user = User.fromDocument(snapShot.data);
          return Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          CachedNetworkImageProvider(user.photoUrl),
                      radius: 40,
                    ),
                    Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                BuildCount("Posts", postCount.toString()),
                                BuildCount("Followers", "0"),
                                BuildCount("Following", "0"),
                              ],
                            ),
                            buildButton()
                          ],
                        ))
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    user.displayName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    user.bio,
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                )
              ],
            ),
          );
        });
  }

  getProfilePost() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection("usersPosts")
        .orderBy("timestamp", descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  buildToggleViewPost() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
            icon: Icon(
              Icons.grid_on,
              color: postView == 'grid'
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            onPressed: () => setBuildTogglePost("grid")),
        IconButton(
            icon: Icon(
              Icons.list,
              color: postView == 'list'
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            onPressed: () => setBuildTogglePost("list"))
      ],
    );
  }

  setBuildTogglePost(String view) {
    setState(() {
      postView = view;
    });
  }

  buildPostProfile() {
    if (isLoading) {
      return circleProgress();
    } else if (postView == "grid") {
      List<GridTile> gridTile = [];
      posts.forEach((post) {
        gridTile.add(GridTile(
          child: PostTile(post: post),
        ));
      });

      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTile,
      );
    } else if (postView == "list") {
      return Column(
          children: posts
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context, name: "Profile"),
        body: ListView(
          children: [
            buildProfileHeader(),
            Divider(
              height: 2.0,
            ),
            buildToggleViewPost(),
            Divider(
              height: 2.0,
            ),
            buildPostProfile(),
          ],
        ));
  }
}
