import 'package:flutter/material.dart';

AppBar header(context,
    {bool isAppTitle = false, String name, removeBackButton = false}) {
  return AppBar(
    backgroundColor: Theme.of(context).primaryColor,
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      isAppTitle ? "SocialChat" : name,
      style: TextStyle(
          fontSize: isAppTitle ? 40 : 20,
          color: Colors.white,
          fontFamily: isAppTitle ? 'Signatra' : ''),
    ),
    centerTitle: true,
  );
}
