import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shack/models/user_model.dart';

import '../../themes/theme.dart';

class Filters extends StatefulWidget {
  final AppUser? currentUser;
  Filters(this.currentUser);

  @override
  _FiltersState createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  Map<String, dynamic> changeValues = {};
  late RangeValues ageRange;
  var _showMe;
  late int distance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool checkedValue = false;
  bool? isSwitched = true;

  bool isPurchased = false;

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
        .doc(widget.currentUser!.id)
        .set(changeValues, SetOptions(merge: true));
    // lastVisible = null;
    // print('ewew$lastVisible');
  }

  late int freeR;
  late int paidR;

  @override
  void initState() {
    super.initState();
    setState(() {
      freeR = 400;
      paidR =  400;
      if (!isPurchased && widget.currentUser!.maxDistance! > freeR) {
        widget.currentUser!.maxDistance = freeR.round();
        changeValues.addAll({'maximum_distance': freeR.round()});
      } else if (isPurchased &&
          widget.currentUser!.maxDistance! >= paidR) {
        widget.currentUser!.maxDistance = paidR.round();
        changeValues.addAll({'maximum_distance': paidR.round()});
      }
      _showMe = widget.currentUser!.showGender;
      distance = widget.currentUser!.maxDistance!.round();
      ageRange = RangeValues(double.parse(widget.currentUser!.ageRange!['min']),
          (double.parse(widget.currentUser!.ageRange!['max'])));
      isSwitched = widget.currentUser!.isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text(
            "Filters",
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white),
      body: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            color: Colors.white),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50), topRight: Radius.circular(50)),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          "Maximum distance",
                          style: TextStyle(
                              fontSize: 18,
                              color: primaryColor,
                              fontWeight: FontWeight.w500),
                        ),
                        trailing: Text(
                          "$distance Km.",
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Slider(
                            value: distance.toDouble(),
                            inactiveColor: secondryColor,
                            min: 1.0,
                            max: isPurchased
                                ? paidR.toDouble()
                                : freeR.toDouble(),
                            activeColor: primaryColor,
                            onChanged: (val) {
                              changeValues
                                  .addAll({'maximum_distance': val.round()});
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
                          style: TextStyle(
                              fontSize: 18,
                              color: primaryColor,
                              fontWeight: FontWeight.w500),
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
                            labels: RangeLabels('${ageRange.start.round()}',
                                '${ageRange.end.round()}'),
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
              ],
            )
          ),
        ),
      ),
    );
  }
}
