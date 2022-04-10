import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid/models/user_model.dart';
import 'package:flutter_grid/screens/Chat/chatPage.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class Near extends StatefulWidget {
  final User currentUser;
  final List<User> matches;

  Near(this.currentUser, this.matches);

  @override
  _NeareState createState() => _NeareState();
}
class _NeareState extends State<Near> {
  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Near you',
                      style: TextStyle(
                        color: _theme.backgroundColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.more_horiz,
                      ),
                      iconSize: 30.0,
                      color: Colors.white,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Container(
                  height: 120.0,
                  child: widget.matches.length > 0
                      ? ListView.builder(
                    padding: EdgeInsets.only(left: 10.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.matches.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          pushNewScreenWithRouteSettings(
                            context,
                            screen: ChatPage(
                              sender: widget.currentUser,
                              chatId: chatId(widget.currentUser, widget.matches[index]),
                              second: widget.matches[index],
                            ),
                            withNavBar: false,
                            pageTransitionAnimation: PageTransitionAnimation.cupertino,
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: _theme.backgroundColor,
                                radius: 35.0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(90),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.matches[index].imageUrl[0],
                                    useOldImageOnUrlChange: true,
                                    placeholder: (context, url) =>
                                        CupertinoActivityIndicator(
                                          radius: 15,
                                        ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ),
                              SizedBox(height: 6.0),
                              Text(
                                widget.matches[index].name,
                                style: TextStyle(
                                  color: _theme.backgroundColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                      : Center(
                      child: Text(
                        "No match found",
                        style: TextStyle(color: _theme.backgroundColor, fontSize: 16),
                      ))),
            ],
          ),
        ),
      ),
    );
  }
}

var groupChatId;
chatId(currentUser, sender) {
  if (currentUser.id.hashCode <= sender.id.hashCode) {
    return groupChatId = '${currentUser.id}-${sender.id}';
  } else {
    return groupChatId = '${sender.id}-${currentUser.id}';
  }
}
