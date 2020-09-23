import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'pages/home.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Social Network",
      theme: ThemeData(
        primaryColor: Colors.blue[400],
        accentColor: Colors.greenAccent[400],
      ),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

