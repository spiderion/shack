import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid/models/answer_model.dart';
import 'package:flutter_grid/models/question_model.dart';
import 'package:flutter_grid/models/user_model.dart';
import 'package:flutter_grid/screens/Home/Home.dart';
import 'package:flutter_grid/screens/HomeScreen.dart';
import 'package:flutter_grid/screens/Near/Near.dart';
import 'package:flutter_grid/screens/Settings/setting.dart';
import 'package:flutter_grid/screens/Video/MakeVideo.dart';
import 'package:flutter_grid/screens/match/Home.dart';
import 'package:flutter_grid/themes/gridapp_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:video_player/video_player.dart';

List likedByList = [];
List<String?> nearuser = [];
List<Question_model> questions = [];
List<Answer_model> answerlist = [];

class TAB extends StatefulWidget {
  final bool? isPaymentSuccess;
  final String? plan;

  TAB(this.plan, this.isPaymentSuccess);

  @override
  _TABState createState() => _TABState();
}

var alertStyle = AlertStyle(
  animationType: AnimationType.fromTop,
  isCloseButton: false,
  isOverlayTapDismiss: false,
  descStyle: TextStyle(fontWeight: FontWeight.bold),
  descTextAlign: TextAlign.start,
  animationDuration: Duration(milliseconds: 400),
  alertBorder: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(0.0),
    side: BorderSide(
      color: Colors.grey,
    ),
  ),
  titleStyle: TextStyle(
    color: Colors.red,
  ),
  alertAlignment: Alignment.topCenter,
);

class _TABState extends State<TAB> with WidgetsBindingObserver {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  CollectionReference docRef = FirebaseFirestore.instance.collection('Users');
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  List<AppUser> matches = [];
  List<AppUser> newmatches = [];
  AppUser? currentUser;
  List<AppUser> users = [];
  List<AppUser> allusers = [];

  PersistentTabController? _controller;
  bool? _hideNavBar;

  List<PurchaseDetails>? purchases = [];
  dynamic _iap = null; // InAppPurchaseConnection.instance;
  bool isPuchased = false;

  VideoPlayerController? videocontroller;

  AppLifecycleState? _lastLifecycleState;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    if (widget.isPaymentSuccess != null && widget.isPaymentSuccess!) {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        await Alert(
          context: context,
          type: AlertType.success,
          title: "Confirmation",
          onWillPopActive: true,
          desc: "You have successfully subscribed to our ${widget.plan} plan.",
          buttons: [
            DialogButton(
              child: Text(
                "Ok",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              width: 120,
            )
          ],
        ).show();
      });
    }
    _controller = PersistentTabController(initialIndex: 0);
    _hideNavBar = false;
    _getquetions();
    _getAccessItems();
    _getCurrentUser();
    _getMatches();
    _getpastPurchases();
    _getallUsers();
    _setRunning(true);

    Timer.periodic(Duration(seconds: 1000), (timer) {
      updatelocation();
    });
  }

  Map items = {};

  _getAccessItems() async {
    FirebaseFirestore.instance.collection("Item_access").snapshots().listen((doc) {
      if (doc.docs.length > 0) {
        items = doc.docs[0].data();
        print(doc.docs[0].data);
      }

      if (mounted) setState(() {});
    });
  }

  _getquetions() {
    return FirebaseFirestore.instance.collection('questions').snapshots().listen((onData) {
      if (onData.docs.length > 0) {
        onData.docs.forEach((f) {
          Question_model tempmodel = Question_model.fromDocument(f);
          questions.add(tempmodel);
          setState(() {});
        });
      }

      // print('hehehe');
    });
  }

  _getallUsers() async {
    allusers.clear();
    User? user = _firebaseAuth.currentUser;
    QuerySnapshot querySnapshot = await docRef.get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      AppUser temp = AppUser.fromDocument(querySnapshot.docs[i]);
      if (temp.id != user!.uid) allusers.add(temp);
    }
  }

  _getCurrentUser() async {
    User user = _firebaseAuth.currentUser!;
    return docRef.doc("${user.uid}").snapshots().listen((data) async {
      currentUser = AppUser.fromDocument(data);
      videocontroller = VideoPlayerController.network(currentUser!.video!)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
          videocontroller!.play();
          videocontroller!.setLooping(true);
        });
      if (mounted) setState(() {});
      answerlist = [];
      List<Answer_model> tempanswer = [];
      FirebaseFirestore.instance.collection('/Users/${currentUser!.id}/Questions').snapshots().listen((data) {
        data.docs.forEach((element) {
          Answer_model temp = Answer_model.fromDocument(element);
          tempanswer.add(temp);
        });
        print(questions.length);
        print(tempanswer.length);
        for (int i = 0; i < questions.length; i++) {
          bool checkTemp = false;
          for (int j = 0; j < tempanswer.length; j++) {
            if (questions[i].id == tempanswer[j].id) {
              checkTemp = true;
              answerlist.insert(i, tempanswer[j]);
            }
          }
          if (!checkTemp) {
            Answer_model tmp_model = Answer_model(answer: false, id: questions[i].id);
            answerlist.insert(i, tmp_model);
          }
          setState(() {});
        }
      });
      users.clear();
      userRemoved.clear();
      getUserList();
      getLikedByList();
      configurePushNotification(currentUser);
      if (!isPuchased) {
        _getSwipedcount();
      }
      docRef.snapshots().listen((QuerySnapshot event) {
        event.docChanges.forEach((element) async {
          AppUser temp = AppUser.fromDocument(element.doc);
          if (temp.id != currentUser!.id) {
            var nearlength = nearuser.length;

            if (temp.isRunning == true && temp.isActive == true) {
              var distance = calculateDistance(
                      currentUser!.coordinates!['latitude'],
                      currentUser!.coordinates!['longitude'],
                      temp.coordinates!['latitude'],
                      temp.coordinates!['longitude']) *
                  1000;
              if (distance.round() < 100) {
                if (!nearuser.contains(temp.id)) nearuser.add(temp.id);
              } else {
                nearuser.remove(temp.id);
              }
            } else {
              nearuser.remove(temp.id);
            }
            if (nearlength != nearuser.length && nearuser.length != 0) {
              List<AppUser> tempuser = [];
              for (int i = 0; i < nearuser.length; i++) {
                docRef.doc("${nearuser[i]}").snapshots().listen((data) {
                  tempuser.add(AppUser.fromDocument(data));
                });
              }

              Alert(
                context: context,
                style: alertStyle,
                type: AlertType.info,
                title: "RFLUTTER ALERT",
                desc: "There are ${nearuser.length} persons.",
                buttons: [
                  DialogButton(
                    child: Text(
                      "Ok",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      pushNewScreenWithRouteSettings(
                        context,
                        screen: Near(currentUser, tempuser),
                        withNavBar: false,
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                        settings: RouteSettings(),
                      );
                    },
                    color: Color.fromRGBO(0, 179, 134, 1.0),
                    radius: BorderRadius.circular(0.0),
                  ),
                ],
              ).show();
            }
          }
        });
      });
      return; // currentUser!;
    });
  }

  int swipecount = 0;

  _getSwipedcount() {
    FirebaseFirestore.instance
        .collection('/Users/${currentUser!.id}/CheckedUser')
        .where(
          'timestamp',
          isGreaterThan: Timestamp.now().toDate().subtract(Duration(days: 1)),
        )
        .snapshots()
        .listen((event) {
      print(event.docs.length);
      setState(() {
        swipecount = event.docs.length;
      });
      return; //event.docs.length;
    });
  }

  getLikedByList() {
    docRef.doc(currentUser!.id).collection("LikedBy").snapshots().listen((data) async {
      likedByList.addAll(data.docs.map((f) => f['LikedBy']));
    });
  }

  Future<void> _getpastPurchases() async {
    print('in past purchases');
    var response = await _iap?.queryPastPurchases();
    print('response   ${response.pastPurchases}');
    for (PurchaseDetails purchase in response.pastPurchases) {
      if (Platform.isIOS) {
        await _iap?.completePurchase(purchase);
      }
    }
    setState(() {
      purchases = response.pastPurchases;
    });
    if (response.pastPurchases.length > 0) {
      purchases!.forEach((purchase) async {
        print('   ${purchase.productID}');
        await _verifyPuchase(purchase.productID);
      });
    }
  }

  configurePushNotification(AppUser? user) {
    _firebaseMessaging.getToken().then((token) {
      docRef.doc(user!.id).update({
        'pushToken': token,
      });
    });

    /*  _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) async {
        print('===============onLaunch$message');
        if (message['data']['type'] == 'Call') {
          bool iscallling = await _checkcallState(message['data']['channel_id']);
          if (iscallling) {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => Incoming(message['data'])));
          }
        }
      },
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage${message['notification']['title']}');
        if (message['data']['type'] == 'Call') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Incoming(message['data'])));
        } else
          print("object");
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume$message');
        if (message['data']['type'] == 'Call') {
          bool iscallling = await _checkcallState(message['data']['channel_id']);
          if (iscallling) {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => Incoming(message['data'])));
          } else {
            print("Timeout");
          }
        }
      },
    );*/
  }

  _checkcallState(channelId) async {
    bool iscalling = await FirebaseFirestore.instance.collection("calls").doc(channelId).get().then((value) {
      return value.data()!["calling"] ?? false;
    });
    return iscalling;
  }

  /// check if user has pruchased
  PurchaseDetails? _hasPurchased(String productId) {
    return purchases!.firstWhereOrNull((purchase) => purchase.productID == productId);
  }

  ///verifying pourchase of user
  Future<void> _verifyPuchase(String id) async {
    PurchaseDetails? purchase = _hasPurchased(id);

    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      print(purchase.productID);
      if (Platform.isIOS) {
        await _iap.completePurchase(purchase);
        print('Achats antérieurs........$purchase');
        isPuchased = true;
      }
      isPuchased = true;
    } else {
      isPuchased = false;
    }
  }

  Future getUserList() async {
    List checkedUser = [];
    FirebaseFirestore.instance.collection('/Users/${currentUser!.id}/CheckedUser').get().then((data) {
      checkedUser.addAll(data.docs.map((f) => f['DislikedUser']));
      checkedUser.addAll(data.docs.map((f) => f['LikedUser']));
    }).then((_) {
      query().getDocuments().then((data) async {
        if (data.documents.length < 1) {
          print("no more data");
          return;
        }
        users.clear();
        userRemoved.clear();
        for (var doc in data.documents) {
          AppUser temp = AppUser.fromDocument(doc);
          var distance = calculateDistance(
              currentUser!.coordinates!['latitude'],
              currentUser!.coordinates!['longitude'],
              temp.coordinates!['latitude'],
              temp.coordinates!['longitude']);
          temp.distanceBW = distance.round();
          if (checkedUser.any(
            (value) => value == temp.id,
          )) {
          } else {
            if (distance <= currentUser!.maxDistance! &&
                temp.id != currentUser!.id &&
                !temp.isBlocked! &&
                temp.isActive!) {
              users.add(temp);
            }
          }
        }
        if (mounted) setState(() {});
      });
    });
  }

  query() {
    if (currentUser!.showGender == 'everyone') {
      return docRef
          .where(
            'age',
            isGreaterThanOrEqualTo: int.parse(currentUser!.ageRange!['min']),
          )
          .where('age', isLessThanOrEqualTo: int.parse(currentUser!.ageRange!['max']))
          .orderBy('age', descending: false);
    } else {
      return docRef
          .where('editInfo.userGender', isEqualTo: currentUser!.showGender)
          .where(
            'age',
            isGreaterThanOrEqualTo: int.parse(currentUser!.ageRange!['min']),
          )
          .where('age', isLessThanOrEqualTo: int.parse(currentUser!.ageRange!['max']))
          //FOR FETCH USER WHO MATCH WITH USER SEXUAL ORIENTAION
          // .where('sexualOrientation.orientation',
          //     arrayContainsAny: currentUser.sexualOrientation)
          .orderBy('age', descending: false);
    }
  }

  _getMatches() async {
    User user = _firebaseAuth.currentUser!;
    return FirebaseFirestore.instance
        .collection('/Users/${user.uid}/Matches')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((ondata) {
      matches.clear();
      newmatches.clear();
      if (ondata.docs.length > 0) {
        ondata.docs.forEach((f) async {
          DocumentSnapshot doc = await docRef.doc(f.data()['Matches']).get();
          if (doc.exists) {
            AppUser tempuser = AppUser.fromDocument(doc);
            if (tempuser.isActive!) {
              tempuser.distanceBW = calculateDistance(
                      currentUser!.coordinates!['latitude'],
                      currentUser!.coordinates!['longitude'],
                      tempuser.coordinates!['latitude'],
                      tempuser.coordinates!['longitude'])
                  .round();

              matches.add(tempuser);
              newmatches.add(tempuser);
            }
            if (mounted) setState(() {});
          }
        });
      }
    });
  }

  List<Widget> _buildScreens() {
    return [
      Container(child: Home(currentUser, allusers, videocontroller)),
      Container(
        child: HomeScreen(currentUser, matches, newmatches),
      ),
      Container(
        child: Center(child: CardPictures(currentUser, users, swipecount, items)),
      ),
      Container(
        child: MakeVideo(currentUser),
      ),
      Container(child: Setting(currentUser, isPuchased, items)),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    ThemeData _theme = Theme.of(context);
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Gridapp.dice_d6),
        title: "Home",
        activeColorPrimary: _theme.backgroundColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Gridapp.chat),
        title: ("Chat"),
        activeColorPrimary: _theme.backgroundColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Gridapp.heart_empty),
        title: ("Match"),
        activeColorPrimary: _theme.backgroundColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Gridapp.videocam),
        title: ("Video"),
        activeColorPrimary: _theme.backgroundColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.settings),
        title: ("Settings"),
        activeColorPrimary: _theme.backgroundColor,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      hideNavigationBar: _hideNavBar,
      decoration: NavBarDecoration(
          colorBehindNavBar: Colors.indigo,
          borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(20.0), topRight: const Radius.circular(20.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 5.0,
            ),
          ]),
      popAllScreensOnTapOfSelectedTab: true,
      itemAnimationProperties: ItemAnimationProperties(
        duration: Duration(milliseconds: 400),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: ScreenTransitionAnimation(
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style6, // Choose the nav bar style with this property
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    print('hello');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setRunning(true);
    } else {
      _setRunning(false);
    }
  }

  Future<void> _setRunning(bool bool) async {
    Map<String, dynamic> userData = {};
    userData.addAll({'isRunning': bool});
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection("Users").doc(user.uid).update(userData);
  }

  Future<void> updatelocation() async {
    var currentLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    List pm =
        []; //await Geolocator().placemarkFromCoordinates(currentLocation.latitude, currentLocation.longitude);
    Map<String, dynamic> userData = {};
    userData.addAll(
      {
        'location': {
          'latitude': currentLocation.latitude,
          'longitude': currentLocation.longitude,
          'address':
              "${pm[0].locality} ${pm[0].subLocality} ${pm[0].subAdministrativeArea}\n ${pm[0].country} ,${pm[0].postalCode}"
        },
      },
    );
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection("Users").doc(user.uid).update(userData);
  }
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos as double Function(num?);
  var a = 0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}
