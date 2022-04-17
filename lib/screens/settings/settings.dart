import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:shack/models/user_model.dart';
import 'package:shack/screens/Settings/update_number.dart';
import 'package:shack/screens/welcome.dart';

import '../../core/location_ebr.dart';
import '../../themes/theme.dart';

class Settings extends StatefulWidget {
  final AppUser currentUser;
  final bool isPurchased;
  final Map items;

  Settings(this.currentUser, this.isPurchased, this.items);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Map<String, dynamic> changeValues = {};
  late RangeValues ageRange;
  var _showMe;
  late int distance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool checkedValue = false;
  bool? isSwitched = true;

  @override
  void dispose() {
    super.dispose();
    if (changeValues.length > 0) {
      updateData();
    }
  }

  Future updateData() async {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.currentUser.id)
        .set(changeValues, SetOptions(merge: true));
    // lastVisible = null;
    // print('ewew$lastVisible');
  }

  late int freeR;
  late int paidR;

  @override
  void initState() {
    super.initState();
    freeR = widget.items['free_radius'] != null ? int.parse(widget.items['free_radius']) : 400;
    paidR = widget.items['paid_radius'] != null ? int.parse(widget.items['paid_radius']) : 400;
    setState(() {
      if (!widget.isPurchased && widget.currentUser.maxDistance! > freeR) {
        widget.currentUser.maxDistance = freeR.round();
        changeValues.addAll({'maximum_distance': freeR.round()});
      } else if (widget.isPurchased && widget.currentUser.maxDistance! >= paidR) {
        widget.currentUser.maxDistance = paidR.round();
        changeValues.addAll({'maximum_distance': paidR.round()});
      }
      _showMe = widget.currentUser.showGender;
      distance = widget.currentUser.maxDistance!.round();
      ageRange = RangeValues(double.parse(widget.currentUser.ageRange!['min']),
          (double.parse(widget.currentUser.ageRange!['max'])));
      isSwitched = widget.currentUser.isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
          title: Text(
            "Settings",
            style: TextStyle(color: Colors.white),
          ),
          elevation: 0,
          backgroundColor: primaryColor),
      body: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            color: Colors.white),
        child: ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "Set my status",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
                ListTile(
                  title: Card(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("On Grid / Off Grid"),
                        Container(
                          child: Switch(
                            value: isSwitched!,
                            onChanged: (value) async {
                              setState(() {
                                isSwitched = value;
                              });
                              Map<String, dynamic> userData = {};
                              userData.addAll({'isActive': isSwitched});
                              final user = FirebaseAuth.instance.currentUser!;
                              await FirebaseFirestore.instance
                                  .collection("Users")
                                  .doc(user.uid)
                                  .update(userData);
                            },
                          ),
                        ),
                      ],
                    ),
                  )),
                  subtitle: Text("Verify a phone number to secure your account"),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "Account settings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
                ListTile(
                  title: Card(
                      child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Phone Number"),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                              ),
                              child: Text(
                                widget.currentUser.phoneNumber != null
                                    ? "${widget.currentUser.phoneNumber}"
                                    : "Verify Now",
                                style: TextStyle(color: secondryColor),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: secondryColor,
                              size: 15,
                            ),
                          ],
                        ),
                        onTap: () {
                          pushNewScreenWithRouteSettings(context,
                              screen: UpdateNumber(widget.currentUser),
                              withNavBar: false,
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                              settings: RouteSettings());
                        }),
                  )),
                  subtitle: Text("Verify a phone number to secure your account"),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Discovery settings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Card(
                    child: ExpansionTile(
                      key: UniqueKey(),
                      leading: Text(
                        "Current location : ",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      title: Text(
                        widget.currentUser.address!,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                color: Colors.blue,
                                size: 25,
                              ),
                              InkWell(
                                child: Text(
                                  "Change location",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () async {
                                  LocationEBR locationEBR = LocationEBR();
                                  LocationInfo? locationInfo = await locationEBR.getLocationData();
                                  var address = locationInfo?.address.addressLine ?? '';
                                  showCupertinoModalPopup(
                                      context: context,
                                      builder: (ctx) {
                                        return Container(
                                          color: Colors.white,
                                          width: MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context).size.height * .4,
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'New address:',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w300,
                                                      decoration: TextDecoration.none),
                                                ),
                                              ),
                                              Card(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(18.0),
                                                  child: Text(
                                                    address,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w300,
                                                        decoration: TextDecoration.none),
                                                  ),
                                                ),
                                              ),
                                              RaisedButton(
                                                color: Colors.white,
                                                child: Text(
                                                  "Done",
                                                  style: TextStyle(color: primaryColor),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  FirebaseFirestore.instance
                                                      .collection("Users")
                                                      .doc('${widget.currentUser.id}')
                                                      .update({
                                                    'location': {
                                                      'latitude': locationInfo?.locationData.latitude,
                                                      'longitude': locationInfo?.locationData.longitude,
                                                      'address': address
                                                    },
                                                  });
                                                  showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (_) {
                                                        Future.delayed(Duration(seconds: 3), () {
                                                          setState(() {
                                                            widget.currentUser.address = address;
                                                          });

                                                          Navigator.pop(context);
                                                        });
                                                        return Center(
                                                            child: Container(
                                                                width: 160.0,
                                                                height: 120.0,
                                                                decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    shape: BoxShape.rectangle,
                                                                    borderRadius: BorderRadius.circular(20)),
                                                                child: Column(
                                                                  children: <Widget>[
                                                                    Image.asset(
                                                                      "asset/auth/verified.jpg",
                                                                      height: 60,
                                                                      color: primaryColor,
                                                                      colorBlendMode: BlendMode.color,
                                                                    ),
                                                                    Text(
                                                                      "location\nchanged",
                                                                      textAlign: TextAlign.center,
                                                                      style: TextStyle(
                                                                          decoration: TextDecoration.none,
                                                                          color: Colors.black,
                                                                          fontSize: 20),
                                                                    )
                                                                  ],
                                                                )));
                                                      });

                                                  // .then((_) {
                                                  //   Navigator.pop(context);
                                                  // });
                                                },
                                              )
                                            ],
                                          ),
                                        );
                                      });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                  ),
                  child: Text(
                    "Change your location to see members in other city",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Show me",
                            style: TextStyle(fontSize: 18, color: primaryColor, fontWeight: FontWeight.w500),
                          ),
                          ListTile(
                            title: DropdownButton(
                              iconEnabledColor: primaryColor,
                              iconDisabledColor: secondryColor,
                              isExpanded: true,
                              items: [
                                DropdownMenuItem(
                                  child: Text("Man"),
                                  value: "man",
                                ),
                                DropdownMenuItem(child: Text("Woman"), value: "woman"),
                                DropdownMenuItem(child: Text("Everyone"), value: "everyone"),
                              ],
                              onChanged: (dynamic val) {
                                changeValues.addAll({
                                  'showGender': val,
                                });
                                setState(() {
                                  _showMe = val;
                                });
                              },
                              value: _showMe,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          "Maximum distance",
                          style: TextStyle(fontSize: 18, color: primaryColor, fontWeight: FontWeight.w500),
                        ),
                        trailing: Text(
                          "$distance Km.",
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Slider(
                            value: distance.toDouble(),
                            inactiveColor: secondryColor,
                            min: 1.0,
                            max: widget.isPurchased ? paidR.toDouble() : freeR.toDouble(),
                            activeColor: primaryColor,
                            onChanged: (val) {
                              changeValues.addAll({'maximum_distance': val.round()});
                              setState(() {
                                distance = val.round();
                              });
                            }),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          "Age range",
                          style: TextStyle(fontSize: 18, color: primaryColor, fontWeight: FontWeight.w500),
                        ),
                        trailing: Text(
                          "${ageRange.start.round()}-${ageRange.end.round()}",
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: RangeSlider(
                            inactiveColor: secondryColor,
                            values: ageRange,
                            min: 18.0,
                            max: 100.0,
                            divisions: 25,
                            activeColor: primaryColor,
                            labels: RangeLabels('${ageRange.start.round()}', '${ageRange.end.round()}'),
                            onChanged: (val) {
                              changeValues.addAll({
                                'age_range': {
                                  'min': '${val.start.truncate()}',
                                  'max': '${val.end.truncate()}'
                                }
                              });
                              setState(() {
                                ageRange = val;
                              });
                            }),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    "App settings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Notifications",
                              style:
                                  TextStyle(fontSize: 18, color: primaryColor, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Push notifications"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Center(
                          child: Text(
                            "Invite your friends",
                            style: TextStyle(color: primaryColor, fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      // Share.share(
                      //     'check out my website https://deligence.com', //Replace with your dynamic link and msg for invite users
                      //     subject: 'Look what I made!');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Card(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            "Logout",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Logout'),
                            content: Text('Do you want to logout your account?'),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text('No'),
                              ),
                              FlatButton(
                                onPressed: () async {
                                  await _auth.signOut().whenComplete(() {
                                    Navigator.pushReplacement(
                                      context,
                                      CupertinoPageRoute(builder: (context) => WelcomePage()),
                                    );
                                  });
                                },
                                child: Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Center(
                          child: Text(
                            "Delete Account",
                            style: TextStyle(color: primaryColor, fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete Account'),
                            content: Text('Do you want to delete your account?'),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text('No'),
                              ),
                              FlatButton(
                                onPressed: () async {
                                  final user = _auth.currentUser!;
                                  await _deleteUser(user).then((_) async {
                                    await _auth.signOut().whenComplete(() {
                                      Navigator.pushReplacement(
                                        context,
                                        CupertinoPageRoute(builder: (context) => WelcomePage()),
                                      );
                                    });
                                  });
                                },
                                child: Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(10.0),
                //   child: Text(
                //     "Advance Filters",
                //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.all(10.0),
                //   child: Text(
                //     "Ethnicity",
                //     style: TextStyle(fontSize: 14, color: Colors.grey),
                //   ),
                // ),
                // Container(
                //   height: 50,
                //   child: Card(
                //     child: ListView(
                //       scrollDirection: Axis.horizontal,
                //       children: <Widget>[
                //         new Text("Asian"),
                //         new  Checkbox(
                //             value: checkedValue,
                //             onChanged: (bool value){
                //               setState(() {
                //                 checkedValue = value;
                //               });
                //             }
                //         ),
                //         new Text("Black"),
                //         new  Checkbox(
                //             value: checkedValue,
                //             onChanged: (bool value){
                //               setState(() {
                //                 checkedValue = value;
                //               });
                //             }
                //         ),
                //         new Text("Middle Eastern"),
                //         new  Checkbox(
                //             value: checkedValue,
                //             onChanged: (bool value){
                //               setState(() {
                //                 checkedValue = value;
                //               });
                //             }
                //         ),
                //         new Text("Latino"),
                //         new  Checkbox(
                //             value: checkedValue,
                //             onChanged: (bool value){
                //               setState(() {
                //                 checkedValue = value;
                //               });
                //             }
                //         ),
                //         new Text("White"),
                //         new  Checkbox(
                //             value: checkedValue,
                //             onChanged: (bool value){
                //               setState(() {
                //                 checkedValue = value;
                //               });
                //             }
                //         ),
                //         new Text("Other"),
                //         new  Checkbox(
                //             value: checkedValue,
                //             onChanged: (bool value){
                //               setState(() {
                //                 checkedValue = value;
                //               });
                //             }
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.all(10.0),
                //   child: Text(
                //     "Religion",
                //     style: TextStyle(fontSize: 14, color: Colors.grey),
                //   ),
                // ),
                // Container(
                //   height: 50,
                //   child: Card(
                //     child: ListView(
                //       scrollDirection: Axis.horizontal,
                //       children: <Widget>[
                //         new Text("Atheust"),
                //         new  Checkbox(
                //             value: checkedValue,
                //             onChanged: (bool value){
                //               setState(() {
                //                 checkedValue = value;
                //               });
                //             }
                //         ),
                //         new Text("Buffhist"),
                //         new  Checkbox(
                //             value: checkedValue,
                //             onChanged: (bool value){
                //               setState(() {
                //                 checkedValue = value;
                //               });
                //             }
                //         ),
                //         new Text("Christian"),
                //         new  Checkbox(
                //             value: checkedValue,
                //             onChanged: (bool value){
                //               setState(() {
                //                 checkedValue = value;
                //               });
                //             }
                //         ),
                //         new Text("Hindu"),
                //         new  Checkbox(
                //             value: checkedValue,
                //             onChanged: (bool value){
                //               setState(() {
                //                 checkedValue = value;
                //               });
                //             }
                //         ),
                //         new Text("Jewish"),
                //         new  Checkbox(
                //             value: checkedValue,
                //             onChanged: (bool value){
                //               setState(() {
                //                 checkedValue = value;
                //               });
                //             }
                //         ),
                //         new Text("Muslim"),
                //         new  Checkbox(
                //             value: checkedValue,
                //             onChanged: (bool value){
                //               setState(() {
                //                 checkedValue = value;
                //               });
                //             }
                //         ),
                //         new Text("Sikh"),
                //         new  Checkbox(
                //             value: checkedValue,
                //             onChanged: (bool value){
                //               setState(() {
                //                 checkedValue = value;
                //               });
                //             }
                //         ),
                //         new Text("Other"),
                //         new  Checkbox(
                //             value: checkedValue,
                //             onChanged: (bool value){
                //               setState(() {
                //                 checkedValue = value;
                //               });
                //             }
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.all(10.0),
                //   child: Text(
                //     "Smoking",
                //     style: TextStyle(fontSize: 14, color: Colors.grey),
                //   ),
                // ),
                // Container(
                //   height: 50,
                //   child:  Card(
                //     child: Row(
                //       children: <Widget>[
                //         new Text("Yes"),
                //         new  Checkbox(
                //             value: checkedValue,
                //             onChanged: (bool value){
                //               setState(() {
                //                 checkedValue = value;
                //               });
                //             }
                //         ),
                //         new Text("No"),
                //         new  Checkbox(
                //             value: checkedValue,
                //             onChanged: (bool value){
                //               setState(() {
                //                 checkedValue = value;
                //               });
                //             }
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.all(10.0),
                //   child: Text(
                //     "Alcohol",
                //     style: TextStyle(fontSize: 14, color: Colors.grey),
                //   ),
                // ),
                // Card(
                //   child: Row(
                //     children: <Widget>[
                //       new Text("Yes"),
                //       new  Checkbox(
                //           value: checkedValue,
                //           onChanged: (bool value){
                //             setState(() {
                //               checkedValue = value;
                //             });
                //           }
                //       ),
                //       new Text("No"),
                //       new  Checkbox(
                //           value: checkedValue,
                //           onChanged: (bool value){
                //             setState(() {
                //               checkedValue = value;
                //             });
                //           }
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(
                //   height: 50,
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _deleteUser(User user) async {
    await FirebaseFirestore.instance.collection("Users").doc(user.uid).delete();
  }
}
