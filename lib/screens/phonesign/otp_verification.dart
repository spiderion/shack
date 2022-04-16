import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:shack/screens/select_image.dart';
import 'package:shack/screens/welcome.dart';
import 'package:shack/screens/phonesign/otp.dart';
import 'package:shack/screens/util/custom_snackbar.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class Verification extends StatefulWidget {
  final bool updateNumber;
  final String phoneNumber;
  final String? smsVerificationCode;

  Verification(this.phoneNumber, this.smsVerificationCode, this.updateNumber);

  @override
  _VerificationState createState() => _VerificationState();
}

var onTapRecognizer;

class _VerificationState extends State<Verification> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Welcome _login = new Welcome();

  Future updateNumber() async {
    User user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(user.uid)
        .set({'phoneNumber': user.phoneNumber}, SetOptions(merge: true)).then((_) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            Future.delayed(Duration(seconds: 2), () async {});
            return Center(
                child: Container(
                    width: 180.0,
                    height: 200.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          "assets/auth/verified.jpg",
                          height: 100,
                        ),
                        Text(
                          "Phone Number\nChanged\nSuccessfully",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(decoration: TextDecoration.none, color: Colors.black, fontSize: 20),
                        )
                      ],
                    )));
          });
    });
  }

  late String code;

  @override
  void initState() {
    super.initState();
    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pop(context);
      };
  }

  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Verify Phone",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/auth/splash.jpg"), fit: BoxFit.cover),
              color: Colors.white),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: AppBar().preferredSize.height + 30),
                ListTile(
                  title: Text(
                    "WE SENT YOU A CODE TO VERIFY YOUR NUMBER",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: _theme.primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 50),
                  child: RichText(
                    text: TextSpan(
                        text: "Sent to ",
                        children: [
                          TextSpan(
                              text: widget.phoneNumber,
                              style:
                                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 60,
                  margin: EdgeInsets.only(left: 25, right: 25),
                  padding: EdgeInsets.only(left: 5, right: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      border: Border.all(color: _theme.backgroundColor),
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context).focusColor.withOpacity(0.1),
                            blurRadius: 15,
                            offset: Offset(0, 5)),
                      ],
                      color: Colors.white),
                  child: PinCodeTextField(
                    appContext: context,
                    // textInputType: TextInputType.number,
                    length: 6,
                    backgroundColor: Colors.white,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    // shape: PinCodeFieldShape.underline,
                    animationDuration: Duration(milliseconds: 300),
                    //fieldHeight: 50,
                    // fieldWidth: 35,
                    onChanged: (value) {
                      code = value;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: "Didn't get it? ",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                      children: [
                        TextSpan(
                            text: "Send a new code",
                            recognizer: onTapRecognizer,
                            style: TextStyle(
                                color: _theme.backgroundColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                fontSize: 16))
                      ]),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: EdgeInsets.all(25),
                  child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color: _theme.backgroundColor,
                      padding: EdgeInsets.all(8),
                      textColor: _theme.primaryColor,
                      onPressed: () async {
                        showDialog(
                          builder: (context) {
                            Future.delayed(Duration(seconds: 2), () {
                              Navigator.pop(context);
                            });
                            return Center(
                                child: CupertinoActivityIndicator(
                              radius: 20,
                            ));
                          },
                          barrierDismissible: false,
                          context: context,
                        );
                        AuthCredential _phoneAuth = PhoneAuthProvider.credential(
                            verificationId: widget.smsVerificationCode!, smsCode: code);
                        if (widget.updateNumber) {
                          User user = FirebaseAuth.instance.currentUser!;
                          user.updatePhoneNumber(_phoneAuth as PhoneAuthCredential).then((_) => updateNumber()).catchError((e) {
                            CustomSnackbar.snackbar("$e", _scaffoldKey);
                          });
                        } else {
                          FirebaseAuth.instance.signInWithCredential(_phoneAuth).then((authResult) {
                            if (authResult != null) {
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (_) {
                                    Future.delayed(Duration(seconds: 2), () async {
                                      Navigator.pop(context);
                                      await _login.navigationCheck(authResult.user!, context);
                                    });
                                    return Center(
                                        child: Container(
                                            width: 180.0,
                                            height: 200.0,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.circular(20)),
                                            child: Column(
                                              children: <Widget>[
                                                Image.asset(
                                                  "assets/auth/verified.jpg",
                                                  height: 100,
                                                ),
                                                Text(
                                                  "Verified\n Successfully",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      decoration: TextDecoration.none,
                                                      color: Colors.black,
                                                      fontSize: 20),
                                                )
                                              ],
                                            )));
                                  });
                              FirebaseFirestore.instance
                                  .collection('Users')
                                  .where('userId', isEqualTo: authResult.user!.uid)
                                  .get()
                                  .then((QuerySnapshot snapshot) async {
                                if (snapshot.docs.length <= 0) {
                                  await setDataUser(authResult.user!);
                                  Navigator.push(
                                      context, CupertinoPageRoute(builder: (context) => SelectImage()));
                                }
                              });
                            }
                          }).catchError((onError) {
                            CustomSnackbar.snackbar("$onError", _scaffoldKey);
                          });
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      )),
                ),
              ],
            ),
          )),
    );
  }
}
