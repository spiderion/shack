import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shack/screens/sexual_orientation.dart';

class UserName extends StatefulWidget {
  UserName();

  @override
  _UserNameState createState() => _UserNameState();
}

class _UserNameState extends State<UserName> {
  Map<String, dynamic> userData = {};
  String username = '';

  late DateTime selecteddate;
  TextEditingController agecontroller = new TextEditingController();
  TextEditingController gendercontroller = new TextEditingController();

  TextEditingController namecontroller = TextEditingController();

  bool man = false;
  bool woman = false;
  bool other = false;
  bool select = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String? code;

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
        title: Text("New Account"),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(25),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 5, bottom: 5),
                    child: Text(
                      'Name',
                      style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                      child: TextField(
                          controller: namecontroller, decoration: getInputBorder(context, "Type your name"))),
                  Container(
                    padding: EdgeInsets.only(left: 5, top: 15, bottom: 5),
                    child: Text('Age',
                        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  textFieldAge(context, _theme),
                  gender(),
                  inputGender(_theme),
                  infoWidget(),
                  Container(
                    width: double.infinity,
                    height: 50,
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: ElevatedButton(
                        onPressed: () {
                          if (namecontroller.text.trim().length == 0 ||
                              agecontroller.text.trim().length == 0 ||
                              gendercontroller.text.trim().length == 0) return;
                          userData.addAll({'UserName': namecontroller.text.trim()});
                          userData.addAll({
                            'user_DOB': "$selecteddate",
                            'age': ((DateTime.now().difference(selecteddate).inDays) / 365.2425).truncate(),
                          });
                          late var userGender;
                          if (man) {
                            userGender = {'userGender': "man", 'showOnProfile': select};
                          }
                          if (woman) {
                            userGender = {'userGender': "woman", 'showOnProfile': select};
                          }
                          if (other) {
                            userGender = {'userGender': "other", 'showOnProfile': select};
                          }
                          userData.addAll(userGender);
                          Navigator.push(
                              context, CupertinoPageRoute(builder: (context) => SexualOrientation(userData)));
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'NEXT',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        )),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  InputDecoration getInputBorder(BuildContext context, String hint) {
    return InputDecoration(
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(const Radius.circular(10.0)), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
            borderSide: BorderSide(color: Theme.of(context).primaryColor)),
        filled: true,
        hintStyle: TextStyle(color: Colors.grey[800]),
        hintText: hint,
        fillColor: Colors.white70);
  }

  Container infoWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 20, bottom: 20),
      child: Text("By proceading you also agree to the Terms of Service and Privacy Policy.",
          style: TextStyle(color: Colors.black), textAlign: TextAlign.center),
    );
  }

  Container inputGender(ThemeData _theme) {
    return Container(
      child: TextField(
        readOnly: true,
        keyboardType: TextInputType.phone,
        onTap: () {
          showMyDialog();
        },
        controller: gendercontroller,
        decoration: getInputBorder(context, "Input your gender"),
      ),
    );
  }

  Container gender() {
    return Container(
      padding: EdgeInsets.only(left: 5, top: 15, bottom: 5),
      child: Text(
        'Gender',
        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Container textFieldAge(BuildContext context, ThemeData _theme) {
    return Container(
      child: TextField(
        readOnly: true,
        controller: agecontroller,
        onTap: () => showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return Container(
                  height: MediaQuery.of(context).size.height * .25,
                  child: GestureDetector(
                    child: CupertinoDatePicker(
                      backgroundColor: Colors.white,
                      initialDateTime: DateTime(2000, 10, 12),
                      onDateTimeChanged: (DateTime newdate) {
                        setState(() {
                          agecontroller.text = newdate.day.toString() +
                              '/' +
                              newdate.month.toString() +
                              '/' +
                              newdate.year.toString();
                          selecteddate = newdate;
                        });
                      },
                      maximumYear: 2002,
                      minimumYear: 1800,
                      maximumDate: DateTime(2002, 03, 12),
                      mode: CupertinoDatePickerMode.date,
                    ),
                    onTap: () {
                      print(agecontroller.text);
                      Navigator.pop(context);
                    },
                  ));
            }),
        keyboardType: TextInputType.phone,
        decoration: getInputBorder(context, "Type your age"),
      ),
    );
  }

  Future<void> showMyDialog() async {
    ThemeData _theme = Theme.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStates) {
            return AlertDialog(
              title: Text('Select your gender'),
              backgroundColor: Colors.white,
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    DecoratedBox(
                      decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          color: man ? Colors.grey : Colors.white),
                      child: OutlineButton(
                        highlightedBorderColor: _theme.primaryColor,
                        child: Container(
                          height: MediaQuery.of(context).size.height * .065,
                          width: MediaQuery.of(context).size.width * .55,
                          child: Center(
                              child: Text("MAN",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: man ? Colors.white : _theme.backgroundColor,
                                      fontWeight: FontWeight.bold))),
                        ),
                        borderSide: BorderSide(
                            width: 1,
                            style: BorderStyle.solid,
                            color: man ? _theme.backgroundColor : _theme.backgroundColor.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        onPressed: () {
                          setState(() {
                            gendercontroller.text = "Man";
                            woman = false;
                            man = true;
                            other = false;
                          });
                          setStates(() {
                            gendercontroller.text = "Man";
                            woman = false;
                            man = true;
                            other = false;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            color: woman ? Colors.grey : Colors.white),
                        child: OutlineButton(
                          child: Container(
                            height: MediaQuery.of(context).size.height * .065,
                            width: MediaQuery.of(context).size.width * .95,
                            child: Center(
                                child: Text("WOMAN",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: woman ? Colors.white : _theme.backgroundColor,
                                        fontWeight: FontWeight.bold))),
                          ),
                          borderSide: BorderSide(
                            color: woman ? _theme.primaryColor : _theme.backgroundColor,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          onPressed: () {
                            setState(() {
                              gendercontroller.text = "Woman";
                              woman = true;
                              man = false;
                              other = false;
                            });
                            setStates(() {
                              gendercontroller.text = "Woman";
                              woman = true;
                              man = false;
                              other = false;
                            });
                          },
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          color: other ? Colors.grey : Colors.white),
                      child: OutlineButton(
                        focusColor: _theme.primaryColor,
                        highlightedBorderColor: _theme.primaryColor,
                        child: Container(
                          height: MediaQuery.of(context).size.height * .065,
                          width: MediaQuery.of(context).size.width * .75,
                          child: Center(
                              child: Text("OTHER",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: other ? Colors.white : _theme.backgroundColor,
                                      fontWeight: FontWeight.bold))),
                        ),
                        borderSide: BorderSide(
                            width: 1,
                            style: BorderStyle.solid,
                            color: other ? _theme.primaryColor : _theme.backgroundColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        onPressed: () {
                          setState(() {
                            gendercontroller.text = "Other";
                            woman = false;
                            man = false;
                            other = true;
                          });
                          setStates(() {
                            gendercontroller.text = "Other";
                            woman = false;
                            man = false;
                            other = true;
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text('CONTINUE'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
