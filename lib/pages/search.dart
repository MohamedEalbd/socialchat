import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image/image.dart';
import 'package:social_chat/model/user.dart';
import 'package:social_chat/pages/home.dart';
import 'package:social_chat/widgets/header.dart';
import 'package:social_chat/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _textSearch = new TextEditingController();
  Future<QuerySnapshot> searchResult;

  handleSearch(value) {
    Future<QuerySnapshot> users =
        userRef.where('username', isGreaterThanOrEqualTo: value).get();
    setState(() {
      searchResult = users;
    });
  }

  clearSearch() {
    _textSearch.clear();
  }

  buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Container(
        decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(30)),
        child: TextFormField(
          controller: _textSearch,
          decoration: InputDecoration(
            hintText: 'Search For a user',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.account_box),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                clearSearch();
              },
            ),
          ),
          onFieldSubmitted: (value) {
            handleSearch(value);
          },
        ),
      ),
    );
  }

  buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            SvgPicture.asset(
              "assets/images/search.svg",
              height: orientation == Orientation.portrait ? 300 : 200,
            ),
            Text(
              "Find Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 50),
            )
          ],
        ),
      ),
    );
  }

  buildResultSearch() {
    return FutureBuilder<QuerySnapshot>(
        future: searchResult,
        builder: (context, snapShot) {
          if (!snapShot.hasData) {
            return circleProgress();
          }
          List<UserResult> searchdata = [];
          snapShot.data.docs.forEach((doc) {
            User user = User.fromDocument(doc);
            searchdata.add(UserResult(
              user: user,
            ));
          });
          return ListView(
            children: searchdata,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildSearchField(),
        body: searchResult != null ? buildResultSearch() : buildNoContent());
  }
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {},
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                ),
                title: Text(
                  user.username,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(user.displayName, style: TextStyle(
                    color: Colors.grey),),
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
