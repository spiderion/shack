import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid/models/user_model.dart';
import 'package:flutter_grid/screens/Chat/Matches.dart';
import 'package:flutter_grid/screens/Chat/chatPage.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class RecentChats extends StatelessWidget {
  final db = Firestore.instance;
  final AppUser currentUser;
  final List<AppUser> matches;

  RecentChats(this.currentUser, this.matches);

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Expanded(
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                //   topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              child: ListView(
                  physics: ScrollPhysics(),
                  children: matches
                      .map((index) => GestureDetector(
                            onTap: () {
                              pushNewScreenWithRouteSettings(
                                context,
                                screen: ChatPage(
                                  chatId: chatId(currentUser, index),
                                  sender: currentUser,
                                  second: index,
                                ),
                                withNavBar: false,
                                pageTransitionAnimation: PageTransitionAnimation.cupertino,
                              );
                            },
                            child: StreamBuilder(
                                stream: db
                                    .collection("chats")
                                    .document(chatId(currentUser, index))
                                    .collection('messages')
                                    .orderBy('time', descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData)
                                    return Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: CupertinoActivityIndicator(),
                                      ),
                                    );
                                  else if (snapshot.data.documents.length ==
                                      0) {
                                    return Container();
                                  }
                                  index.lastmsg =
                                      snapshot.data.documents[0]['time'];
                                  return Container(
                                    margin: EdgeInsets.only(
                                        top: 5.0, bottom: 5.0, right: 20.0),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: snapshot.data.documents[0]
                                                      ['sender_id'] !=
                                                  currentUser.id &&
                                              !snapshot.data.documents[0]
                                                  ['isRead']
                                          ? _theme.primaryColor.withOpacity(.1)
                                          : _theme.backgroundColor.withOpacity(.2),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20.0),
                                        bottomRight: Radius.circular(20.0),
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: _theme.backgroundColor,
                                        radius: 30.0,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(90),
                                          child: CachedNetworkImage(
                                            imageUrl: index.imageUrl[0],
                                            useOldImageOnUrlChange: true,
                                            placeholder: (context, url) =>
                                                CupertinoActivityIndicator(
                                              radius: 15,
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        index.name,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        snapshot.data.documents[0]['image_url']
                                                    .toString()
                                                    .length >
                                                0
                                            ? "Photo"
                                            : snapshot.data.documents[0]
                                                ['text'],
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            snapshot.data.documents[0]
                                                        ["time"] !=
                                                    null
                                                ? DateFormat.MMMd()
                                                    .add_jm()
                                                    .format(snapshot.data
                                                        .documents[0]["time"]
                                                        .toDate())
                                                    .toString()
                                                : "",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          snapshot.data.documents[0]
                                                          ['sender_id'] !=
                                                      currentUser.id &&
                                                  !snapshot.data.documents[0]
                                                      ['isRead']
                                              ? Container(
                                                  width: 40.0,
                                                  height: 20.0,
                                                  decoration: BoxDecoration(
                                                    color: _theme.primaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'NEW',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                              : Text(""),
                                          snapshot.data.documents[0]
                                                      ['sender_id'] ==
                                                  currentUser.id
                                              ? !snapshot.data.documents[0]
                                                      ['isRead']
                                                  ? Icon(
                                                      Icons.done,
                                                      color: _theme.backgroundColor,
                                                      size: 15,
                                                    )
                                                  : Icon(
                                                      Icons.done_all,
                                                      color: _theme.primaryColor,
                                                      size: 15,
                                                    )
                                              : Text("")
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ))
                      .toList()),
            )));
  }
}
