import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid/models/user_model.dart';
import 'package:flutter_grid/screens/Chat/Matches.dart';
import 'package:flutter_grid/screens/Chat/chatPage.dart';
import 'package:flutter_grid/screens/Profile/EditProfile.dart';
import 'package:flutter_grid/screens/util/color.dart';

class Info extends StatelessWidget {
  final AppUser? currentUser;
  final AppUser? user;

  final GlobalKey? swipeKey;

  Info(
    this.user,
    this.currentUser,
    this.swipeKey,
  );

  @override
  Widget build(BuildContext context) {
    bool isMe = user!.id == currentUser!.id;
    bool isMatched = swipeKey == null;
    //  if()

    //matches.any((value) => value.id == user.id);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    final ThemeData _theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: <Widget>[
            Container(
              height: mediaQueryData.size.height / 2 + 40,
              width: MediaQuery.of(context).size.width,
              child: Text(
                  "Swiper") /*Swiper(
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
                            placeholder: (context, url) => CupertinoActivityIndicator(
                              radius: 20,
                            ),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        )
                      : Container();
                },
                itemCount: user.imageUrl.length,
                pagination: new SwiperPagination(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.only(bottom: 120),
                    builder: DotSwiperPaginationBuilder(
                        activeSize: 13, color: _theme.backgroundColor, activeColor: _theme.primaryColor)),
                control: new SwiperControl(
                  color: _theme.primaryColor,
                  disableColor: _theme.backgroundColor,
                ),
                loop: false,
              )*/
              ,
            ),
            Positioned(
              bottom: 0,
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                      color: Colors.white),
                  height: mediaQueryData.size.height / 2,
                  width: mediaQueryData.size.width,
                  padding: const EdgeInsets.only(top: 30.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 5),
                          alignment: Alignment.center,
                          child: Text(
                            'On Grid',
                            style: TextStyle(color: _theme.backgroundColor),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            "${user!.name}, ${user!.age}",
                            style: TextStyle(
                                color: _theme.backgroundColor, fontSize: 35, fontWeight: FontWeight.w900),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 20),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              color: Colors.white,
                              child: Column(
                                children: <Widget>[
                                  !isMe
                                      ? ListTile(
                                          dense: true,
                                          leading: Icon(
                                            Icons.location_on,
                                            color: primaryColor,
                                          ),
                                          title: Text(
                                            "${user!.editInfo!['DistanceVisible'] != null ? user!.editInfo!['DistanceVisible'] ? 'Less than ${user!.distanceBW} KM away' : 'Distance not visible' : 'Less than ${user!.distanceBW} KM away'}",
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        )
                                      : Container(),
                                  Divider(
                                    color: primaryColor,
                                    height: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        isMe
                            ? Container()
                            : Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text('SwipeDetector'),
/*                                    SwipeDetector(
                                      child: Container(
                                        child: Column(
                                          children: <Widget>[
                                            Icon(
                                              Icons.keyboard_arrow_up,
                                              color: primaryColor,
                                              size: 40,
                                            ),
                                            Text(
                                              'Swipe up to view profile',
                                              style: TextStyle(color: primaryColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onSwipeUp: () {
                                        showMaterialModalBottomSheet(
                                          expand: false,
                                          context: context,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) => Material(
                                              color: Colors.transparent,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(20),
                                                        topRight: Radius.circular(20)),
                                                    color: Colors.white),
                                                child: Stack(
                                                  children: <Widget>[
                                                    SwipeWidget(user, currentUser),
                                                    Container(
                                                      child: Align(
                                                        alignment: Alignment.bottomRight,
                                                        child: Container(
                                                          width: 80,
                                                          height: 200,
                                                          padding: const EdgeInsets.only(
                                                              right: 10, left: 15, top: 15, bottom: 15),
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius.circular(20),
                                                                  bottomLeft: Radius.circular(20)),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors.grey,
                                                                  blurRadius: 5.0,
                                                                )
                                                              ],
                                                              color: Colors.white),
                                                          child: Align(
                                                            alignment: Alignment.bottomCenter,
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                              children: <Widget>[
                                                                InkWell(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  onTap: () {},
                                                                  splashColor: Colors.blue,
                                                                  highlightColor: Colors.blue,
                                                                  child: Container(
                                                                    height: 50,
                                                                    width: 50,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        border:
                                                                            Border.all(color: Colors.yellow),
                                                                        color: Colors.yellow),
                                                                    child: Center(
                                                                      child: Icon(
                                                                        Icons.star,
                                                                        color: Colors.white,
                                                                        size: 40,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                InkWell(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  onTap: () {
                                                                    Navigator.pop(context);
                                                                    Navigator.pop(context);
                                                                    swipeKey.currentState.swipeRight();
                                                                  },
                                                                  splashColor: Colors.blue,
                                                                  highlightColor: Colors.blue,
                                                                  child: Container(
                                                                    height: 50,
                                                                    width: 50,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        border: Border.all(
                                                                            color: Colors.greenAccent),
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
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                InkWell(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  onTap: () {
                                                                    Navigator.pop(context);
                                                                    Navigator.pop(context);
                                                                    swipeKey.currentState.swipeLeft();
                                                                  },
                                                                  child: Container(
                                                                    height: 50,
                                                                    width: 50,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        border:
                                                                            Border.all(color: Colors.black54),
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
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                width: mediaQueryData.size.width,
                                                height: mediaQueryData.size.height * 3 / 4,
                                              )),
                                        );
                                      },
                                      swipeConfiguration: SwipeConfiguration(
                                          verticalSwipeMinVelocity: 100.0,
                                          verticalSwipeMinDisplacement: 50.0,
                                          verticalSwipeMaxWidthThreshold: 100.0,
                                          horizontalSwipeMaxHeightThreshold: 50.0,
                                          horizontalSwipeMinDisplacement: 50.0,
                                          horizontalSwipeMinVelocity: 200.0),
                                    )*/
                                    GridView.count(
                                        physics: NeverScrollableScrollPhysics(),
                                        crossAxisCount: 3,
                                        shrinkWrap: true,
                                        crossAxisSpacing: 4,
                                        padding: EdgeInsets.all(10),
                                        children: List.generate(3, (index) {
                                          return Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Container(
                                                decoration: user!.imageUrl!.length > index
                                                    ? BoxDecoration()
                                                    : BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        border: Border.all(
                                                            style: BorderStyle.solid,
                                                            width: 1,
                                                            color: Theme.of(context).backgroundColor)),
                                                child: Stack(
                                                  children: <Widget>[
                                                    user!.imageUrl!.length > index
                                                        ? CachedNetworkImage(
                                                            height: MediaQuery.of(context).size.height * .2,
                                                            fit: BoxFit.cover,
                                                            imageUrl: user!.imageUrl![index],
                                                            placeholder: (context, url) => Center(
                                                              child: CupertinoActivityIndicator(
                                                                radius: 10,
                                                              ),
                                                            ),
                                                            errorWidget: (context, url, error) => Center(
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: <Widget>[
                                                                  Icon(
                                                                    Icons.error,
                                                                    color: Colors.black,
                                                                    size: 25,
                                                                  ),
                                                                  Text(
                                                                    "Enable to load",
                                                                    style: TextStyle(
                                                                      color: Colors.black,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        })),
                                  ],
                                ),
                              )
                      ],
                    ),
                  )),
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
                          borderRadius: BorderRadius.all(Radius.circular(5)), color: Colors.white),
                      child: Image.asset(
                        'assets/auth/map_mark.png',
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  )),
            ),
            !isMatched
                ? Container(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: 80,
                        height: 200,
                        padding: const EdgeInsets.only(right: 10, left: 15, top: 15, bottom: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5.0,
                              )
                            ],
                            color: Colors.white),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
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
                                      border: Border.all(color: Colors.yellow),
                                      color: Colors.yellow),
                                  child: Center(
                                    child: Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  Navigator.pop(context);
                                  // swipeKey.currentState.swipeRight();
                                },
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
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  Navigator.pop(context);
                                  // swipeKey.currentState.swipeLeft();
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
                            ],
                          ),
                        ),
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
                                    context, CupertinoPageRoute(builder: (context) => EditProfile(user))))),
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
