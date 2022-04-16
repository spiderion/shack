import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shack/models/user_model.dart';
import 'package:shack/screens/tab.dart';
import 'package:shack/screens/util/color.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:template_package/template_package.dart';
import 'package:video_player/video_player.dart';

class Home extends StatefulWidget {
  final AppUser? currentUser;
  final List<AppUser> users;
  final VideoPlayerController? controller;

  Home(this.currentUser, this.users, this.controller);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController searchcontroller = new TextEditingController();
  List<AppUser> searchuser = [];

  GlobalKey swipeKey = GlobalKey();

  SwiperController _controllers = new SwiperController();
  int currentindex = 0;

  @override
  void initState() {
    super.initState();
    searchuser = widget.users;
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);
    final ThemeData _theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/auth/city.jpg"), fit: BoxFit.cover),
              color: Colors.white),
          padding: EdgeInsets.only(top: media.padding.top),
          height: MediaQuery.of(context).size.height,
          child: stackBody(media, context)),
    );
  }

  Widget stackBody(MediaQueryData media, BuildContext context) {
    return Stack(
      children: <Widget>[
        list(media),
        widget.currentUser == null ? loader(context) : swiper(context, media),
        Positioned(
          top: 180,
          child: searchWidget(media),
        )
      ],
    );
  }

  Widget searchWidget(MediaQueryData media) {
    return Container(
      width: media.size.width - 60,
      margin: EdgeInsets.only(left: 30, right: 30),
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: primaryColor),
      child: Row(
        children: <Widget>[title(), Expanded(child: Container(child: searchTextField()))],
      ),
    );
  }

  Widget searchTextField() {
    return TextField(
      textAlign: TextAlign.start,
      controller: searchcontroller,
      decoration: new InputDecoration(
          border: new OutlineInputBorder(
            borderRadius:
                const BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
          ),
          contentPadding: EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
          hintStyle: new TextStyle(color: Colors.grey[800]),
          hintText: "Search"),
      onChanged: (text) {
        search(text);
      },
    );
  }

  Widget title() {
    return Container(
      width: 100,
      child: Text('THE GRID',
          textAlign: TextAlign.center, style: TextStyle(color: secondryColor, fontWeight: FontWeight.bold)),
    );
  }

  Container swiper(BuildContext context, MediaQueryData media) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
      ),
      height: 200,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          Swiper(
            key: UniqueKey(),
            physics: ScrollPhysics(),
            itemBuilder: (BuildContext context, int index2) {
              return Container(
                width: media.size.width,
                height: 200,
                decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage("assets/auth/lib.jpg"), fit: BoxFit.cover),
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))),
              );
            },
            itemCount: 1,
            pagination: new SwiperPagination(
                alignment: Alignment.bottomCenter,
                builder:
                    DotSwiperPaginationBuilder(activeSize: 10, color: Colors.grey, activeColor: Colors.white),
                margin: EdgeInsets.only(bottom: 30)),
            control: new SwiperControl(color: Colors.white, disableColor: Colors.grey),
            loop: false,
          ),
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Column(
              children: <Widget>[
                Text(
                  widget.currentUser?.name ?? '',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 39),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  widget.currentUser!.address!,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Container loader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
      ),
      height: 200,
      width: MediaQuery.of(context).size.width,
      child: isInDebugMode
          ? Text('loading')
          : Image.asset(
              'assets/loading.gif',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            ),
    );
  }

  Positioned list(MediaQueryData media) {
    return Positioned(
        top: 190,
        child: Container(
          width: media.size.width,
          height: media.size.height - 190,
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
            SizedBox(
              height: 50,
            ),
            Container(
              width: media.size.width,
              height: 80,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: searchuser.length,
                  itemBuilder: (context, index) {
                    return Container(
                        width: 80,
                        padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              decoration:
                                  BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.green),
                              width: 50,
                              height: 50,
                              padding: EdgeInsets.all(1),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10), color: Colors.white),
                                child: searchuser[index].imageUrl!.length != null
                                    ? CachedNetworkImage(
                                        imageUrl: searchuser[index].imageUrl![0],
                                        fit: BoxFit.cover,
                                        imageBuilder: (context, imageProvider) => Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              image:
                                                  DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                                        ),
                                        useOldImageOnUrlChange: true,
                                        placeholder: (context, url) => CupertinoActivityIndicator(
                                          radius: 20,
                                        ),
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                      )
                                    : isInDebugMode
                                        ? Text('loading')
                                        : Image.asset('assets/loading.gif', fit: BoxFit.cover),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(top: 2),
                              child: Text(
                                searchuser[index].name!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: primaryColor,
                                ),
                                maxLines: 1,
                              ),
                            )
                          ],
                        ));
                  }),
            ),
            Expanded(
                child: SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: Container(
                      height: media.size.width + 100,
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            width: media.size.width,
                            child: questions.length != 0 && answerlist.length != 0
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      Container(
                                          alignment: Alignment.center,
                                          child: Swiper(
                                            index: currentindex,
                                            itemBuilder: (BuildContext context, int indexs) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10),
                                                    color: primaryColor),
                                                width: media.size.width - 60,
                                                height: (media.size.width - 60) * 8 / 16,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      questions[indexs].title ?? '',
                                                      style: TextStyle(
                                                        color: secondryColor,
                                                        fontSize: 25,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Text(
                                                      questions[indexs].title ?? 'title',
                                                      style: TextStyle(
                                                        color: secondryColor,
                                                        fontSize: 20,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    answerlist[indexs] != null
                                                        ? Text(
                                                            'Your answer is ' +
                                                                (answerlist[indexs].answer == true
                                                                    ? 'yes'
                                                                    : 'no'),
                                                            style: TextStyle(
                                                              color: secondryColor,
                                                              fontSize: 15,
                                                            ),
                                                            textAlign: TextAlign.center,
                                                          )
                                                        : Container()
                                                  ],
                                                ),
                                              );
                                            },
                                            itemCount: questions.length,
                                            layout: SwiperLayout.TINDER,
                                            itemHeight: (media.size.width - 60) * 8 / 16,
                                            itemWidth: media.size.width - 30,
                                            controller: _controllers,
                                            onIndexChanged: (inde) {
                                              currentindex = inde;
                                            },
                                          )),
                                      Container(
                                        width: media.size.width - 44,
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            InkWell(
                                              borderRadius: BorderRadius.circular(5),
                                              onTap: () {
                                                // print(currentindex);
                                                FirebaseFirestore.instance
                                                    .collection("Users")
                                                    .doc(widget.currentUser!.id)
                                                    .collection('Questions')
                                                    .doc(questions[currentindex].id)
                                                    .set({'id': questions[currentindex].id, 'answer': false});
                                              },
                                              child: Container(
                                                height: 50,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(5),
                                                    border: Border.all(color: Colors.grey),
                                                    color: Colors.grey),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.clear,
                                                    color: primaryColor,
                                                    size: 40,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              borderRadius: BorderRadius.circular(5),
                                              onTap: () {
                                                FirebaseFirestore.instance
                                                    .collection("Users")
                                                    .doc(widget.currentUser!.id)
                                                    .collection('Questions')
                                                    .doc(questions[currentindex].id)
                                                    .set({'id': questions[currentindex].id, 'answer': true});
                                              },
                                              splashColor: Colors.blue,
                                              highlightColor: Colors.blue,
                                              child: Container(
                                                height: 50,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(5),
                                                    border: Border.all(color: Colors.greenAccent),
                                                    color: Colors.greenAccent),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.check,
                                                    color: primaryColor,
                                                    size: 40,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10), color: primaryColor),
                                    width: media.size.width - 60,
                                    height: (media.size.width - 60) * 8 / 16,
                                    alignment: Alignment.center,
                                  ),
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 20),
                              child: widget.controller != null
                                  ? (widget.controller!.value.isInitialized
                                      ? Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          width: media.size.width - 60,
                                          height: (media.size.width - 60) * 8 / 16,
                                          child: AspectRatio(
                                              aspectRatio: widget.controller!.value.aspectRatio,
                                              child: ClipRect(
                                                child: VideoPlayer(widget.controller!),
                                              )),
                                        )
                                      : isInDebugMode
                                          ? Text('loading')
                                          : Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  image: DecorationImage(
                                                      image: Image.asset(
                                                        'assets/loading.gif',
                                                        fit: BoxFit.contain,
                                                      ).image,
                                                      fit: BoxFit.cover)),
                                              width: media.size.width - 60,
                                              height: (media.size.width - 60) * 8 / 16,
                                            ))
                                  : isInDebugMode
                                      ? Text('loading')
                                      : Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              image: DecorationImage(
                                                  image: Image.asset(
                                                    'assets/loading.gif',
                                                    fit: BoxFit.contain,
                                                  ).image,
                                                  fit: BoxFit.cover)),
                                          width: media.size.width - 60,
                                          height: (media.size.width - 60) * 8 / 16,
                                        )),
                        ],
                      ),
                    )))
          ]),
        ));
  }

  void search(String text) {
    searchuser = [];
    if (text.length == 0) {
      setState(() {
        searchuser = widget.users;
      });
    } else {
      for (int i = 0; i < widget.users.length; i++) {
        if (widget.users[i].name!.toLowerCase().contains(text.toLowerCase())) {
          searchuser.add(widget.users[i]);
        }
      }
      setState(() {});
    }
  }
}
