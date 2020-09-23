import 'package:flutter/material.dart';
import 'package:social_chat/widgets/header.dart';

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,name: "ActivityFeed"),
      body: Center(
        child: Text("ActivityFeed"),
      ),
    );
  }
}
