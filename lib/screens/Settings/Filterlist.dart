import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_grid/models/user_model.dart';
import 'package:flutter_grid/screens/util/color.dart';
import 'package:image/image.dart' as i;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class Filterlist extends StatefulWidget {
  final User currentUser;
  Filterlist(this.currentUser);

  @override
  FilterlistState createState() => FilterlistState();
}

class FilterlistState extends State<Filterlist> {
  Map<String, dynamic> changeValues = {};
  RangeValues ageRange;
  var _showMe;
  int distance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool checkedValue = false;
  bool isSwitched = true;

  @override
  void initState() {
    super.initState();
    // setState(() {
    //   if (!widget.isPurchased && widget.currentUser.maxDistance > freeR) {
    //     widget.currentUser.maxDistance = freeR.round();
    //     changeValues.addAll({'maximum_distance': freeR.round()});
    //   } else if (widget.isPurchased &&
    //       widget.currentUser.maxDistance >= paidR) {
    //     widget.currentUser.maxDistance = paidR.round();
    //     changeValues.addAll({'maximum_distance': paidR.round()});
    //   }
    //   _showMe = widget.currentUser.showGender;
    //   distance = widget.currentUser.maxDistance.round();
    //   ageRange = RangeValues(double.parse(widget.currentUser.ageRange['min']),
    //       (double.parse(widget.currentUser.ageRange['max'])));
    //   isSwitched = widget.currentUser.isActive;
    // });
  }

  @override
  void dispose() {
    super.dispose();
    if (changeValues.length > 0) {
      updateData();
    }
  }
  Future updateData() async {
    Firestore.instance
        .collection("Users")
        .document(widget.currentUser.id)
        .setData(changeValues, merge: true);
    // lastVisible = null;
    // print('ewew$lastVisible');
  }

  @override
  Widget build(BuildContext context) {
    // Profile _profile = new Profile(widget.currentUser);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          elevation: 0,
          title: Text(
            "Filters",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.black,
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.white),
      body: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
        ),
      ),
    );
  }
}
