
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_grid/screens/ShowGender.dart';
import 'package:flutter_grid/screens/SignUp.dart';
import 'package:flutter_grid/screens/util/CustomSnackbar.dart';

class SexualOrientation extends StatefulWidget {
  final Map<String, dynamic> userData;
  SexualOrientation(this.userData);

  @override
  _SexualOrientationState createState() => _SexualOrientationState();
}


class _SexualOrientationState extends State<SexualOrientation> {
  List<Map<String, dynamic>> orientationlist = [
    {'name': 'Straight', 'ontap': false},
    {'name': 'Gay', 'ontap': false},
    {'name': 'Asexual', 'ontap': false},
    {'name': 'Lesbian', 'ontap': false},
    {'name': 'Bisexual', 'ontap': false},
    {'name': 'Demisexual', 'ontap': false},
  ];
  List selected = [];
  bool? select = false;
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
        title: Text("My sexual orientation"),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 25, right: 25),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: Text(
                    "My sexual\norientation is",
                    style: TextStyle(fontSize: 40),
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.only(top: 10),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 70, vertical: 50),
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: orientationlist.length,
                    itemBuilder: (BuildContext context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: OutlineButton(
                          highlightedBorderColor: _theme.primaryColor,
                          child: Container(
                            height: MediaQuery.of(context).size.height * .055,
                            width: MediaQuery.of(context).size.width * .65,
                            child: Center(
                                child: Text("${orientationlist[index]["name"]}",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: orientationlist[index]["ontap"]
                                            ? _theme.primaryColor
                                            : _theme.backgroundColor,
                                        fontWeight: FontWeight.bold))),
                          ),
                          borderSide: BorderSide(
                              width: 1,
                              style: BorderStyle.solid,
                              color: orientationlist[index]["ontap"]
                                  ? _theme.primaryColor
                                  : _theme.backgroundColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          onPressed: () {
                            setState(() {
                              if (selected.length < 3) {
                                orientationlist[index]["ontap"] =
                                !orientationlist[index]["ontap"];
                                if (orientationlist[index]["ontap"]) {
                                  selected.add(orientationlist[index]["name"]);
                                  print(orientationlist[index]["name"]);
                                  print(selected);
                                } else {
                                  selected.remove(orientationlist[index]["name"]);
                                  print(selected);
                                }
                              } else {
                                if (orientationlist[index]["ontap"]) {
                                  orientationlist[index]["ontap"] =
                                  !orientationlist[index]["ontap"];
                                  selected.remove(orientationlist[index]["name"]);
                                } else {
                                  CustomSnackbar.snackbar(
                                      "select upto 3", _scaffoldKey);
                                }
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Checkbox(
                        activeColor: _theme.backgroundColor,
                        value: select,
                        onChanged: (bool? newValue) {
                          setState(() {
                            select = newValue;
                          });
                        },
                      ),
                      title: Text("Show my orientation on my profile"),
                    ),

                    selected.length > 0
                        ? Container(
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
                            widget.userData.addAll({
                              "sexualOrientation": {
                                'orientation': selected,
                                'showOnProfile': select
                              },
                            });
                            print(widget.userData);
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        ShowGender(widget.userData)));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Text('CONTINUE',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15
                              ),
                              textAlign: TextAlign.center,),
                          )
                      ),
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
                              height:
                              MediaQuery.of(context).size.height * .065,
                              width:
                              MediaQuery.of(context).size.width * .75,
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
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}
