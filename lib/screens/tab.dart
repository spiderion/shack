import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shack/core/data/data_paths.dart';
import 'package:shack/core/location_ebr.dart';
import 'package:shack/models/answer_model.dart';
import 'package:shack/models/question_model.dart';
import 'package:shack/models/user_model.dart';
import 'package:shack/screens/Near/near.dart';
import 'package:shack/screens/Settings/setting.dart';
import 'package:shack/screens/Video/make_video.dart';
import 'package:shack/screens/home/home.dart';
import 'package:shack/screens/home_screen.dart';
import 'package:shack/screens/match/home.dart';
import 'package:shack/themes/gridapp_icons.dart';
import 'package:video_player/video_player.dart';

List likedByList = [];
List<String?> nearuser = [];
List<QuestionModel> questions = [];
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
    side: BorderSide(color: Colors.grey),
  ),
  titleStyle: TextStyle(color: Colors.red),
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
  List<AppUser> allUsers = [];

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
    _getQuestions();
    _getAccessItems();
    _getCurrentUser();
    _getMatches();
    _getpastPurchases();
    _getAllUsers();
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

  _getQuestions() {
    return FirebaseFirestore.instance
        .collection(Collections.QUESTIONS)
        .snapshots()
        .listen((QuerySnapshot onData) {
      if (onData.docs.length > 0) {
        onData.docs.forEach((f) {
          QuestionModel tempModel = QuestionModel.fromDocument(f.data() as Map<String, dynamic>? ?? {});
          questions.add(tempModel);
          setState(() {});
        });
      }
    });
  }

  _getAllUsers() async {
    allUsers.clear();
    User? user = _firebaseAuth.currentUser;
    QuerySnapshot querySnapshot = await docRef.get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      AppUser temp = AppUser.fromDocument(querySnapshot.docs[i].data() as Map<String, dynamic>);
      if (temp.id != user!.uid) allUsers.add(temp);
    }
  }

  _getCurrentUser() async {
    User? user = _firebaseAuth.currentUser;
    return docRef.doc("${user?.uid}").snapshots().listen((DocumentSnapshot doc) async {
      currentUser = AppUser.fromDocument(doc.data() as Map<String, dynamic>);
      videocontroller = VideoPlayerController.network(currentUser!.video!)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
          videocontroller?.play();
          videocontroller?.setLooping(true);
        });
      if (mounted) setState(() {});
      answerlist = [];
      List<Answer_model> tempanswer = [];
      FirebaseFirestore.instance
          .collection('/${Collections.Users}/${currentUser!.id}/${Collections.Questions}')
          .snapshots()
          .listen((QuerySnapshot data) {
        data.docs.forEach((element) {
          print('hey');
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
            Answer_model tmpModel = Answer_model(answer: false, id: questions[i].id);
            answerlist.insert(i, tmpModel);
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
          AppUser temp = AppUser.fromDocument(element.doc.data() as Map<String, dynamic>);
          if (temp.id != currentUser?.id) {
            final nearlength = nearuser.length;
            if (temp.isRunning == true && temp.isActive == true) {
              var distance = calculateDistance(
                      currentUser?.coordinates?['latitude'] ?? 0,
                      currentUser?.coordinates?['longitude'] ?? 0,
                      temp.coordinates?['latitude'] ?? 0,
                      temp.coordinates?['longitude'] ?? 0) *
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
                  tempuser.add(AppUser.fromDocument(data.data() as Map<String, dynamic>? ?? {}));
                });
              }
              // todo add later
              return;
              Alert(
                context: context,
                style: alertStyle,
                type: AlertType.info,
                title: "RFLUTTER ALERT",
                desc: "There are ${nearuser.length} persons.",
                buttons: [
                  DialogButton(
                    child: Text("Ok", style: TextStyle(color: Colors.white, fontSize: 20)),
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
        .collection('/${Collections.Users}/${currentUser!.id}/${Collections.CheckedUser}')
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
    docRef.doc(currentUser?.id).collection("LikedBy").snapshots().listen((data) async {
      likedByList.addAll(data.docs.map((f) => f['LikedBy']));
    });
  }

  Future<void> _getpastPurchases() async {
    print('in past purchases');
    var response = await _iap?.queryPastPurchases();
    print('response   ${response?.pastPurchases}');
    for (PurchaseDetails purchase in response.pastPurchases) {
      if (Platform.isIOS) {
        await _iap?.completePurchase(purchase);
      }
    }
    setState(() {
      purchases = response.pastPurchases;
    });
    if ((response?.pastPurchases?.length ?? 0) > 0) {
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

  Future<bool> _checkcallState(channelId) async {
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
    if (currentUser == null) return [];
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
        for (DocumentSnapshot doc in data.documents) {
          AppUser temp = AppUser.fromDocument(doc.data() as Map<String, dynamic>? ?? {});
          final distance = calculateDistance(
              currentUser?.coordinates?['latitude'],
              currentUser?.coordinates?['longitude'],
              temp.coordinates?['latitude'],
              temp.coordinates?['longitude']);
          temp.distanceBW = distance.round();
          if (checkedUser.any((value) => value == temp.id)) {
            print('checkedUser');
          } else {
            if (distance <= (currentUser?.maxDistance ?? 0) &&
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
            AppUser tempuser = AppUser.fromDocument(doc.data() as Map<String, dynamic>);
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
      Container(child: Home(currentUser, allUsers, videocontroller)),
      Container(child: HomeScreen(currentUser, matches, newmatches)),
      Container(child: Center(child: CardPictures(currentUser, users, swipecount, items))),
      Container(child: MakeVideo(currentUser)),
      Setting(currentUser, isPuchased, items)
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    ThemeData _theme = Theme.of(context);
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Gridapp.dice_d6),
        title: "Home",
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Gridapp.chat),
        title: ("Chat"),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Gridapp.heart_empty),
        title: ("Match"),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Gridapp.videocam),
        title: ("Video"),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.settings),
        title: ("Settings"),
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
            BoxShadow(color: Colors.grey, blurRadius: 5.0),
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
    WidgetsBinding.instance?.removeObserver(this);
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
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection("Users").doc(user?.uid).update(userData);
  }

  Future<void> updatelocation() async {
    LocationEBR locationEBR = LocationEBR();
    LocationInfo? locationInfo = await locationEBR.getLocationData();
    Map<String, dynamic> userData = {};
    userData.addAll(
      {
        'location': {
          'latitude': locationInfo?.locationData.latitude,
          'longitude': locationInfo?.locationData.longitude,
          'address': locationInfo?.address.addressLine ?? ''
        },
      },
    );
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection("Users").doc(user.uid).update(userData);
  }
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}
