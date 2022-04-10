import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid/models/user_model.dart';
import 'package:flutter_grid/screens/util/color.dart';
import 'package:video_player/video_player.dart';

class Home1 extends StatefulWidget {
  final AppUser currentUser;
  final List<AppUser> users;
  final VideoPlayerController controller;

  Home1(this.currentUser, this.users, this.controller);

  @override
  _Home1State createState() => _Home1State();
}

class _Home1State extends State<Home1> {
  TextEditingController searchcontroller = new TextEditingController();
  List<AppUser> searchuser = [];

  @override
  void initState() {
    super.initState();
    searchuser = widget.users;
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.dispose();
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
          child: Stack(
            children: <Widget>[
              Positioned(
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
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10), color: Colors.green),
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
                                                        image: DecorationImage(
                                                            image: imageProvider, fit: BoxFit.cover)),
                                                  ),
                                                  useOldImageOnUrlChange: true,
                                                  placeholder: (context, url) => CupertinoActivityIndicator(
                                                    radius: 20,
                                                  ),
                                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                                )
                                              : Image.asset(
                                                  'assets/loading.gif',
                                                  fit: BoxFit.cover,
                                                ),
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
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  color: primaryColor),
                                              width: media.size.width - 60,
                                              height: (media.size.width - 60) * 8 / 16,
                                              alignment: Alignment.center,
                                              child: Text(
                                                'KISSES \nON THE \nFOREHEAD?',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: secondryColor, fontSize: 20),
                                              ),
                                            ),
                                            Container(
                                              width: media.size.width - 44,
                                              alignment: Alignment.center,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  InkWell(
                                                    borderRadius: BorderRadius.circular(10),
                                                    onTap: () {},
                                                    child: Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
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
                                                    borderRadius: BorderRadius.circular(10),
                                                    onTap: () {},
                                                    splashColor: Colors.blue,
                                                    highlightColor: Colors.blue,
                                                    child: Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
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
                                        )),
                                    Container(
                                        padding: EdgeInsets.only(top: 20),
                                        child: widget.controller != null
                                            ? (widget.controller.value.isInitialized
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    width: media.size.width - 60,
                                                    height: (media.size.width - 60) * 8 / 16,
                                                    child: AspectRatio(
                                                      aspectRatio: widget.controller.value.aspectRatio,
                                                      child: VideoPlayer(widget.controller),
                                                    ),
                                                  )
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
                  )),
              widget.currentUser == null
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                      ),
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Image.asset(
                        'assets/loading.gif',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                      ),
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: <Widget>[
                          Text("Swiper")
/*                          Swiper(
                            key: UniqueKey(),
                            physics: ScrollPhysics(),
                            itemBuilder: (BuildContext context, int index2) {
                              return widget.currentUser.imageUrl.length != null
                                  ? Hero(
                                      tag: "abc",
                                      child: CachedNetworkImage(
                                        imageUrl: widget.currentUser.imageUrl[index2],
                                        fit: BoxFit.cover,
                                        useOldImageOnUrlChange: true,
                                        placeholder: (context, url) => CupertinoActivityIndicator(
                                          radius: 20,
                                        ),
                                        imageBuilder: (context, imageProvider) => Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(10),
                                                  bottomRight: Radius.circular(10)),
                                              image:
                                                  DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                                        ),
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                      ),
                                    )
                                  : Container();
                            },
                            itemCount: widget.currentUser.imageUrl.length,
                            pagination: new SwiperPagination(
                                alignment: Alignment.bottomCenter,
                                builder: DotSwiperPaginationBuilder(
                                    activeSize: 10, color: Colors.grey, activeColor: Colors.white),
                                margin: EdgeInsets.only(bottom: 30)),
                            control: new SwiperControl(
                              color: Colors.white,
                              disableColor: Colors.grey,
                            ),
                            loop: false,
                          )*/,
                          Positioned(
                            top: 50,
                            left: 0,
                            right: 0,
                            child: Column(
                              children: <Widget>[
                                Text(
                                  widget.currentUser.name!,
                                  style: TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.w900, fontSize: 25),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  widget.currentUser.address!,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
              Positioned(
                top: 180,
                child: Container(
                  width: media.size.width - 60,
                  margin: EdgeInsets.only(left: 30, right: 30),
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: primaryColor),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 100,
                        child: Text(
                          'THE GRID',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: secondryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                          child: Container(
                        child: TextField(
                          textAlign: TextAlign.start,
                          controller: searchcontroller,
                          decoration: new InputDecoration(
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                            ),
                            contentPadding: EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
                            hintStyle: new TextStyle(color: Colors.grey[800]),
                            hintText: "Search",
                          ),
                          onChanged: (text) {
                            search(text);
                          },
                        ),
                      ))
                    ],
                  ),
                ),
              )
            ],
          )),
    );
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
