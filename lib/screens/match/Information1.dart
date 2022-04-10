import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid/models/user_model.dart';
import 'package:flutter_grid/screens/Chat/Matches.dart';
import 'package:flutter_grid/screens/Chat/chatPage.dart';
import 'package:flutter_grid/screens/Profile/EditProfile.dart';
import 'package:flutter_grid/screens/util/color.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:swipe_stack/swipe_stack.dart';


class Info1 extends StatelessWidget {
  final AppUser currentUser;
  final AppUser user;

  final GlobalKey<SwipeStackState> swipeKey;
  Info1(
    this.user,
    this.currentUser,
    this.swipeKey,
  );

  @override
  Widget build(BuildContext context) {
    bool isMe = user.id == currentUser.id;
    bool isMatched = swipeKey == null;
    //  if()

    //matches.any((value) => value.id == user.id);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    final ThemeData _theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white),
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: <Widget>[
            Container(
              height: mediaQueryData.size.height / 2 + 40,
              width: MediaQuery.of(context).size.width,
              child: Swiper(
                key: UniqueKey(),
                physics: ScrollPhysics(),
                itemBuilder: (BuildContext context, int index2) {
                  return user.imageUrl.length != null
                      ? Hero(
                    tag: "abc",
                    child: CachedNetworkImage(
                      imageUrl: user.imageUrl[index2],
                      fit: BoxFit.cover,
                      useOldImageOnUrlChange: true,
                      placeholder: (context, url) =>
                          CupertinoActivityIndicator(
                            radius: 20,
                          ),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error),
                    ),
                  )
                      : Container();
                },
                itemCount: user.imageUrl.length,
                pagination: new SwiperPagination(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.only(bottom: 120),
                    builder: DotSwiperPaginationBuilder(
                        activeSize: 13,
                        color: _theme.backgroundColor,
                        activeColor: _theme.primaryColor)),
                control: new SwiperControl(
                  color: _theme.primaryColor,
                  disableColor: _theme.backgroundColor,
                ),
                loop: false,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                      color: Colors.white),
                  height: mediaQueryData.size.height / 2,
                  width: mediaQueryData.size.width,
                  padding: const EdgeInsets.all(30.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 5),
                          alignment: Alignment.center,
                          child: Text('On Grid', style: TextStyle(color: _theme.backgroundColor),),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            "${user.name}, ${user.age}",
                            style: TextStyle(
                                color: _theme.backgroundColor,
                                fontSize: 35,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 40),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              color: Colors.white,
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    subtitle: Text("${user.address}"),
                                    title: Text(
                                      "${user.name}, ${user.editInfo['showMyAge'] != null ? !user.editInfo['showMyAge'] ? user.age : "" : user.age}",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    // trailing: FloatingActionButton(
                                    //     backgroundColor: Colors.white,
                                    //     onPressed: () {
                                    //       Navigator.pop(context);
                                    //     },
                                    //     child: Icon(
                                    //       Icons.arrow_downward,
                                    //       color: primaryColor,
                                    //     )),
                                  ),
                                  user.editInfo['job_title'] != null
                                      ? ListTile(
                                    dense: true,
                                    leading:
                                    Icon(Icons.work, color: primaryColor),
                                    title: Text(
                                      "${user.editInfo['job_title']}${user.editInfo['company'] != null ? ' at ${user.editInfo['company']}' : ''}",
                                      style: TextStyle(
                                          color: secondryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                      : Container(),
                                  user.editInfo['university'] != null
                                      ? ListTile(
                                    dense: true,
                                    leading:
                                    Icon(Icons.stars, color: primaryColor),
                                    title: Text(
                                      "${user.editInfo['university']}",
                                      style: TextStyle(
                                          color: secondryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                      : Container(),
                                  user.editInfo['living_in'] != null
                                      ? ListTile(
                                    dense: true,
                                    leading:
                                    Icon(Icons.home, color: primaryColor),
                                    title: Text(
                                      "Living in ${user.editInfo['living_in']}",
                                      style: TextStyle(
                                          color: secondryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                      : Container(),
                                  !isMe
                                      ? ListTile(
                                    dense: true,
                                    leading: Icon(
                                      Icons.location_on,
                                      color: primaryColor,
                                    ),
                                    title: Text(
                                      "${user.editInfo['DistanceVisible'] != null ? user.editInfo['DistanceVisible'] ? 'Less than ${user.distanceBW} KM away' : 'Distance not visible' : 'Less than ${user.distanceBW} KM away'}",
                                      style: TextStyle(
                                          color: secondryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                      : Container(),
                                  Divider(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        user.editInfo['about'] != null
                            ? Text(
                          "${user.editInfo['about']}",
                          style: TextStyle(
                              color: secondryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        )
                            : Container(),
                        SizedBox(
                          height: 100,
                        ),
                      ],
                    ),
                  )
              ),
            ),
            Positioned(
              bottom: mediaQueryData.size.height / 2 - 30,
              child: Container(
                  width: mediaQueryData.size.width,
                  alignment: Alignment.center,
                  height: 60,
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.white),
                      child: Image.asset('assets/auth/map_mark.png', fit: BoxFit.fitHeight,),
                    ),
                  )
              ),
            ),
            !isMatched
                ? Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              Navigator.pop(context);
                              swipeKey.currentState.swipeLeft();
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.black54),
                                  color: Colors.black54),
                              child: Center(
                                child: Icon(
                                  Icons.clear,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              Navigator.pop(context);
                              swipeKey.currentState.swipeRight();
                            },
                            splashColor: Colors.blue,
                            highlightColor: Colors.blue,
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                  Border.all(color: Colors.greenAccent),
                                  color: Colors.greenAccent),
                              child: Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : isMe
                    ? Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Align(
                            alignment: Alignment.bottomRight,
                            child: FloatingActionButton(
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.edit,
                                  color: primaryColor,
                                ),
                                onPressed: () => Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            EditProfile(user))))),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Align(
                            alignment: Alignment.bottomRight,
                            child: FloatingActionButton(
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.message,
                                  color: primaryColor,
                                ),
                                onPressed: () => Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => ChatPage(
                                              sender: currentUser,
                                              second: user,
                                              chatId: chatId(user, currentUser),
                                            ))))),
                      )
          ],
        ),
      ),
    );
  }
}
