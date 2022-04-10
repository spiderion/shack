
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid/screens/SelectImage.dart';
import 'package:flutter_grid/screens/Tab.dart';
import 'package:flutter_grid/screens/phonesign/otp.dart';
import 'package:flutter_grid/themes/gridapp_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Welcome extends StatelessWidget {

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
              Container(
                decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/auth/city.jpg"), fit: BoxFit.cover),
              color: Colors.white),
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.only(top: mediaQueryData.padding.top),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(25),
                      child: Text(
                        'THE GRID',
                        style: TextStyle(
                          color: _theme.primaryColor,
                          fontSize: 30,
                          fontWeight: FontWeight.w900
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        'THE SOCIAL\n DATING\nMOVEMENT',
                        style: TextStyle(
                            color: _theme.primaryColor,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: mediaQueryData.size.width,
                  height: mediaQueryData.size.height * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                      borderRadius: new BorderRadius.only(
                          topLeft:  const  Radius.circular(20.0),
                          topRight: const  Radius.circular(20.0))
                  ),
                  padding: EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 20),
                        child: Text("""Lorem ipsum dolor sit amet, consectetur
adipiscing elit, sed do eiusmod tempor incididunt
ut labore et dolore magna aliqua.""",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16
                        ),
                        textAlign: TextAlign.center,),
                      ),
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
                          onPressed: (){
                            bool updateNumber = false;
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) =>  OTP(updateNumber)));
                          },
                          child: Stack(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(left: 5),
                                alignment: Alignment.centerLeft,
                                child: Icon(
                                  Gridapp.phone_squared,
                                  size: 30,
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: Text('SIGN UP WITH PHONE',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15
                                  ),
                                textAlign: TextAlign.center,),
                              )
                            ],
                          ),
                        ),
                      ),
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
                          onPressed: (){
                          },
                          child: Stack(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(left: 5),
                                alignment: Alignment.centerLeft,
                                child: Icon(
                                  Icons.music_video,
                                  size: 30,
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: Text('SIGN UP WITH SPOTIFY',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15
                                  ),
                                  textAlign: TextAlign.center,),
                              )
                            ],
                          ),
                        ),
                      ),
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
                          onPressed: (){
                          },
                          child: Stack(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(left: 5),
                                alignment: Alignment.centerLeft,
                                child: Icon(
                                  Gridapp.at,
                                  size: 30,
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: Text('SIGN UP WITH EMAIL',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15
                                  ),
                                  textAlign: TextAlign.center,),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Text("""By proceading you also agree to the Terms of
Service and Privacy Policy.""",
                          style: TextStyle(
                              color: Colors.black,
                          ),
                          textAlign: TextAlign.center,),
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
        )
    );
  }
  Future navigationCheck(FirebaseUser currentUser, context) async {
    await Firestore.instance
        .collection('Users')
        .where('userId', isEqualTo: currentUser.uid)
        .getDocuments()
        .then((QuerySnapshot snapshot) async {
      if (snapshot.documents.length > 0) {
        if (snapshot.documents[0].data['location'] != null) {
          Navigator.push(context,
              CupertinoPageRoute(builder: (context) => TAB(null, null)));
        } else {
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => SelectImage()));
        }
      } else {
        await _setDataUser(currentUser);
        Navigator.push(
            context, CupertinoPageRoute(builder: (context) => SelectImage()));
      }
    });
  }
  Future _setDataUser(FirebaseUser user) async {
    await Firestore.instance.collection("Users").document(user.uid).setData(
      {
        'userId': user.uid,
        'UserName': user.displayName,
        'phoneNumber': user.phoneNumber,
        'timestamp': FieldValue.serverTimestamp()
      },
      merge: true,
    );
  }
}
