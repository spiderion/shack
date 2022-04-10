import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_grid/screens/AllowLocation.dart';
import 'package:flutter_grid/screens/SignUp.dart';
import 'package:flutter_grid/screens/util/CustomSnackbar.dart';

class ShowGender extends StatefulWidget {
  final Map<String, dynamic> userData;

  ShowGender(this.userData);

  @override
  _ShowGenderState createState() => _ShowGenderState();
}

class _ShowGenderState extends State<ShowGender> {
  bool man = false;
  bool woman = false;
  bool eyeryone = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Show me"),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  OutlineButton(
                    highlightedBorderColor: _theme.primaryColor,
                    child: Container(
                      height: MediaQuery.of(context).size.height * .065,
                      width: MediaQuery.of(context).size.width * .75,
                      child: Center(
                          child: Text("MEN",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: man
                                      ? _theme.primaryColor
                                      : _theme.backgroundColor,
                                  fontWeight: FontWeight.bold))),
                    ),
                    borderSide: BorderSide(
                        width: 1,
                        style: BorderStyle.solid,
                        color:
                            man ? _theme.primaryColor : _theme.backgroundColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    onPressed: () {
                      setState(() {
                        woman = false;
                        man = true;
                        eyeryone = false;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: OutlineButton(
                      child: Container(
                        height: MediaQuery.of(context).size.height * .065,
                        width: MediaQuery.of(context).size.width * .75,
                        child: Center(
                            child: Text("WOMEN",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: woman
                                        ? _theme.primaryColor
                                        : _theme.backgroundColor,
                                    fontWeight: FontWeight.bold))),
                      ),
                      borderSide: BorderSide(
                        color: woman
                            ? _theme.primaryColor
                            : _theme.backgroundColor,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      onPressed: () {
                        setState(() {
                          woman = true;
                          man = false;
                          eyeryone = false;
                        });
                        // Navigator.push(
                        //     context, CupertinoPageRoute(builder: (context) => OTP()));
                      },
                    ),
                  ),
                  OutlineButton(
                    focusColor: _theme.primaryColor,
                    highlightedBorderColor: _theme.primaryColor,
                    child: Container(
                      height: MediaQuery.of(context).size.height * .065,
                      width: MediaQuery.of(context).size.width * .75,
                      child: Center(
                          child: Text("EVERYONE",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: eyeryone
                                      ? _theme.primaryColor
                                      : _theme.backgroundColor,
                                  fontWeight: FontWeight.bold))),
                    ),
                    borderSide: BorderSide(
                        width: 1,
                        style: BorderStyle.solid,
                        color: eyeryone
                            ? _theme.primaryColor
                            : _theme.backgroundColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    onPressed: () {
                      setState(() {
                        woman = false;
                        man = false;
                        eyeryone = true;
                      });
                      // Navigator.push(
                      //     context, CupertinoPageRoute(builder: (context) => OTP()));
                    },
                  ),
                ],
              ),
            ),
            man || woman || eyeryone
                ? Container(
                    width: double.infinity,
                    height: 50,
                    margin: EdgeInsets.only(
                        top: 10, bottom: 10, left: 25, right: 25),
                    child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: _theme.backgroundColor,
                        padding: EdgeInsets.all(8),
                        textColor: _theme.primaryColor,
                        onPressed: () {
                          if (man) {
                            widget.userData.addAll({'showGender': "man"});
                          } else if (woman) {
                            widget.userData.addAll({'showGender': "woman"});
                          } else {
                            widget.userData.addAll({'showGender': "everyone"});
                          }

                          print(widget.userData);
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) =>
                                      AllowLocation(widget.userData)));
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'CONTINUE',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        )),
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            height: MediaQuery.of(context).size.height * .065,
                            width: MediaQuery.of(context).size.width * .75,
                            child: Center(
                                child: Text(
                              "CONTINUE",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: _theme.backgroundColor,
                                  fontWeight: FontWeight.bold),
                            ))),
                        onTap: () {
                          CustomSnackbar.snackbar(
                              "Please select one", _scaffoldKey);
                        },
                      ),
                    ),
                  )
          ],
        ));
  }
}
