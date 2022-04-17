import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shack/screens/phonesign/otp.dart';
import 'package:shack/screens/select_image.dart';
import 'package:shack/screens/tab.dart';
import 'package:shack/themes/gridapp_icons.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
        backgroundColor: _theme.backgroundColor,
        body: Container(
            width: double.infinity,
            height: double.infinity,
            color: _theme.backgroundColor,
            child: Stack(
              children: <Widget>[
                background(mediaQueryData, _theme),
                titleWidget(_theme),
                Align(alignment: Alignment.center, child: signUpActions(mediaQueryData, _theme, context))
              ],
            )));
  }

  Widget signUpActions(MediaQueryData mediaQueryData, ThemeData _theme, BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      width: mediaQueryData.size.width,
      height: mediaQueryData.size.height * 0.6,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.0))),
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Continue with Phone',
              style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
          ),
          Container(
            width: double.infinity,
            height: 50,
            margin: EdgeInsets.only(top: 10, bottom: 10),
            child: getButton(context, () {
              bool updateNumber = false;
              Navigator.push(context, CupertinoPageRoute(builder: (context) => OTP(updateNumber)));
            }, 'Sign up with Phone', Gridapp.phone_squared),
          ),
          divider(),
          Container(
              width: double.infinity,
              height: 50,
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: getButton(context, () {}, 'Sign up with spotify', Icons.music_video)),
          Container(
            width: double.infinity,
            height: 50,
            margin: EdgeInsets.only(top: 10, bottom: 10),
            child: getButton(context, () {}, 'Sign up with email', Gridapp.at),
          ),
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              """By proceading you also agree to the Terms of
Service and Privacy Policy.""",
              style: TextStyle(
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Row divider() {
    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'or continue with',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            Expanded(child: Divider())
          ],
        );
  }

  Widget getButton(BuildContext context, Function() onTap, String text, IconData icon) {
    return ElevatedButton(
      style: ButtonStyle(),
      onPressed: onTap,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 5),
            alignment: Alignment.centerLeft,
            child: Icon(icon, size: 30, color: Colors.white),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Widget titleWidget(ThemeData _theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Image.asset('assets/images/app_logo.png', height: 28),
            ),
            Container(
              child: Flexible(
                child: Text(
                  'The social dating movement',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget background(MediaQueryData mediaQueryData, ThemeData _theme) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/images/splash_screen.jpg"), fit: BoxFit.cover),
          color: Colors.white),
      padding: EdgeInsets.only(top: mediaQueryData.padding.top),
    );
  }

  Future navigationCheck(User currentUser, context) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .where('userId', isEqualTo: currentUser.uid)
        .get()
        .then((QuerySnapshot snapshot) async {
      if (snapshot.docs.length > 0) {
        if ((snapshot.docs[0].data() as Map)['location'] != null) {
          Navigator.push(context, CupertinoPageRoute(builder: (context) => TAB(null, null)));
        } else {
          Navigator.push(context, CupertinoPageRoute(builder: (context) => SelectImage()));
        }
      } else {
        await _setDataUser(currentUser);
        Navigator.push(context, CupertinoPageRoute(builder: (context) => SelectImage()));
      }
    });
  }

  Future _setDataUser(User user) async {
    await FirebaseFirestore.instance.collection("Users").doc(user.uid).set({
      'userId': user.uid,
      'UserName': user.displayName,
      'phoneNumber': user.phoneNumber,
      'timestamp': FieldValue.serverTimestamp()
    }, SetOptions(merge: true));
  }
}
