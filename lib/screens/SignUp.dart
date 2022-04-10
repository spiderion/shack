import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid/screens/Introscreen.dart';

class SignUp extends StatefulWidget {
  final Map<String, dynamic> userData;

  SignUp(this.userData);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _setUserData(widget.userData);
  }

  Future _setUserData(Map<String, dynamic> userData) async {
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection("Users").doc(user.uid).set(userData, SetOptions(merge: true));
  }

  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Sign Up",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/auth/pool.jpg"), fit: BoxFit.cover),
            color: Colors.white),
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: _theme.primaryColor,
                        borderRadius: new BorderRadius.all(Radius.circular(20.0))),
                    width: 160,
                    height: 160,
                    margin: EdgeInsets.only(bottom: 30),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 150,
                    ),
                  ),
                  ListTile(
                      title: Text(
                        "SIGN UP\nSUCCESSFUL",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 35, fontWeight: FontWeight.w900, color: _theme.primaryColor),
                      ),
                      subtitle: Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          "You can start using the app now",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      )),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: mediaQueryData.size.width,
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          color: _theme.backgroundColor,
                          padding: EdgeInsets.all(8),
                          textColor: _theme.primaryColor,
                          onPressed: () {
                            Navigator.push(context, CupertinoPageRoute(builder: (context) => Introscreen()));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'START',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
