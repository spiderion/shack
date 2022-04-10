import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_grid/screens/Splash.dart';
import 'package:flutter_grid/themes/theme.dart';
import 'package:flutter_grid/screens/SelectImage.dart';
import 'package:flutter_grid/screens/Tab.dart';
import 'package:flutter_grid/screens/Welcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    // Overrides the status bar and navigation style.
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Color(0xaa7ab3fa),
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xaa7ab3fa),
    ));
  }
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  bool isLoading = true;
  bool isAuth = false;
  bool isRegistered = false;
  @override
  void initState() {
    super.initState();
    checkAuth();
  }
  checkAuth() {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.currentUser().then((FirebaseUser user) async {
      if (user != null) {

        await Firestore.instance
            .collection('Users')
            .where('userId', isEqualTo: user.uid)
            .getDocuments()
            .then((QuerySnapshot snapshot) async {
          if (snapshot.documents.length > 0) {
            if (snapshot.documents[0].data['location'] != null) {
              setState(() {
                isRegistered = true;
              });
            } else {
              setState(() {
                isAuth = true;
              });
            }
            print("loggedin ${user.uid}");
          }
        });
      }
      setState(() {
        isLoading = false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: CustomeTheme.lightTheme,
      home: isLoading
          ? Splash()
          : isRegistered ? TAB(null, null) : isAuth ? SelectImage() : Welcome(),
    );
  }
}
