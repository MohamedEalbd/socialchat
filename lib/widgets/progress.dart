import 'package:flutter/material.dart';
Container circleProgress(){
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.blue[400]),
    ),
  );
}
Container linearProgress(){
  return Container(
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.blue[400]),
    ),
  );
}