import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid/models/user_model.dart';
import 'package:flutter_grid/screens/Settings/Addphoto.dart';
import 'package:flutter_grid/screens/Settings/EditBio.dart';
import 'package:flutter_grid/screens/Settings/Filters.dart';
import 'package:flutter_grid/screens/util/color.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:template_package/template_package.dart';

class Setting extends StatefulWidget {
  final AppUser? currentUser;
  final bool isPurchased;
  final Map items;

  Setting(this.currentUser, this.isPurchased, this.items);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  Map<String, dynamic> changeValues = {};
  RangeValues? ageRange;
  String? _showMe;
  int? distance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool checkedValue = false;
  bool? isSwitched = true;

  Future updateData() async {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.currentUser?.id)
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
      if (!widget.isPurchased && getUserMaxDistance() > freeR) {
        widget.currentUser?.maxDistance = freeR.round();
        changeValues.addAll({'maximum_distance': freeR.round()});
      } else if (widget.isPurchased && getUserMaxDistance() >= paidR) {
        widget.currentUser?.maxDistance = paidR.round();
        changeValues.addAll({'maximum_distance': paidR.round()});
      }
      _showMe = widget.currentUser?.showGender;
      distance = getUserMaxDistance().round();
      final min = double.parse(widget.currentUser?.ageRange?['min'] ?? '18');
      final max = double.parse(widget.currentUser?.ageRange?['max'] ?? '30');
      ageRange = RangeValues(min, max);
      isSwitched = widget.currentUser?.isActive ?? false;
    });
  }

  int getUserMaxDistance() => (widget.currentUser?.maxDistance ?? 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text("Settings", style: TextStyle(color: Colors.black)),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: ClipRRect(
          child: SingleChildScrollView(
              child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              Container(
                alignment: Alignment.center,
                child: widget.currentUser == null
                    ? Container(
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                        child: isInDebugMode
                            ? Text('loading')
                            : Image.asset('assets/loading.gif',
                                fit: BoxFit.cover, width: double.infinity, height: 200),
                      )
                    : Container(
                        height: 400,
                        width: MediaQuery.of(context).size.width - 50,
                        child: Swiper(
                          key: UniqueKey(),
                          physics: ScrollPhysics(),
                          itemBuilder: (BuildContext context, int index2) {
                            return widget.currentUser?.imageUrl?.length != null
                                ? Hero(
                                    tag: "abcd",
                                    child: CachedNetworkImage(
                                      imageUrl: widget.currentUser?.imageUrl?[index2],
                                      fit: BoxFit.cover,
                                      useOldImageOnUrlChange: true,
                                      placeholder: (context, url) => CupertinoActivityIndicator(radius: 20),
                                      imageBuilder: (context, imageProvider) => Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                                      ),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    ),
                                  )
                                : Container();
                          },
                          itemCount: widget.currentUser?.imageUrl?.length ?? 0,
                          pagination: new SwiperPagination(
                              alignment: Alignment.bottomCenter,
                              builder: DotSwiperPaginationBuilder(
                                  activeSize: 13, color: secondryColor, activeColor: primaryColor),
                              margin: EdgeInsets.only(bottom: 40)),
                          control: new SwiperControl(
                            color: primaryColor,
                            disableColor: secondryColor,
                          ),
                          loop: false,
                        ),
                      ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "${widget.currentUser?.name}, ${widget.currentUser?.age}",
                  style: TextStyle(color: primaryColor, fontSize: 35, fontWeight: FontWeight.w900),
                ),
              ),
              ListTile(
                dense: true,
                leading: Icon(
                  Icons.location_on,
                  color: primaryColor,
                ),
                title: Text(
                  "${widget.currentUser?.address}",
                  style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 25, right: 25, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            pushNewScreenWithRouteSettings(context,
                                screen: EditBio(widget.currentUser),
                                withNavBar: false,
                                pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                settings: RouteSettings());
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: primaryColor),
                                color: primaryColor),
                            child: Center(
                              child: Icon(Icons.settings, color: Colors.white, size: 40),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text('Edit Bio', style: TextStyle(color: primaryColor, fontSize: 15)),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            pushNewScreenWithRouteSettings(context,
                                screen: Addphoto(widget.currentUser),
                                withNavBar: false,
                                pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                settings: RouteSettings());
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: primaryColor),
                                color: primaryColor),
                            child: Center(child: Icon(Icons.person_outline, color: Colors.white, size: 40)),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            'Add Photos',
                            style: TextStyle(color: primaryColor, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            pushNewScreenWithRouteSettings(context,
                                screen: Filters(widget.currentUser),
                                withNavBar: false,
                                pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                settings: RouteSettings());
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: primaryColor),
                                color: primaryColor),
                            child: Center(
                              child: Icon(
                                Icons.tune,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            'Edit Filters',
                            style: TextStyle(color: primaryColor, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          height: 60,
                          width: 60,
                          child: Center(
                            child: CupertinoSwitch(
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
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            'Grid Status',
                            style: TextStyle(color: primaryColor, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              upgradeButton(),
            ],
          )),
        ),
      ),
    );
  }

  Widget upgradeButton() {
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.only(top: 10, bottom: 30),
      padding: EdgeInsets.only(left: 25, right: 25),
      child: FlatButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          color: primaryColor,
          padding: EdgeInsets.all(8),
          textColor: secondryColor,
          onPressed: () => Fluttertoast.showToast(msg: 'coming soon'),
          child: Container(
            alignment: Alignment.center,
            child: Text('UPGRADE TO PREMIUM',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15), textAlign: TextAlign.center),
          )),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (changeValues.length > 0) {
      updateData();
    }
  }
}
