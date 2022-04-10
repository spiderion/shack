import 'package:flutter/material.dart';
import 'package:flutter_grid/models/user_model.dart';
import 'package:flutter_grid/screens/Chat/Matches.dart';
import 'package:flutter_grid/screens/Chat/recent_chats.dart';

class HomeScreen extends StatefulWidget {
  final AppUser currentUser;
  final List<AppUser> matches;
  final List<AppUser> newmatches;
  HomeScreen(this.currentUser, this.matches, this.newmatches);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 500), () {
      if (widget.matches.length > 0 && widget.matches[0].lastmsg != null) {
        widget.matches.sort((a, b) {
          var adate = a.lastmsg; //before -> var adate = a.expiry;
          var bdate = b.lastmsg; //before -> var bdate = b.expiry;
          return bdate?.compareTo(
              adate); //to get the order other way just switch `adate & bdate`
        });
        setState(() {});
      }
    });
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
      backgroundColor: _theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: _theme.backgroundColor,
        automaticallyImplyLeading: false,
        title: Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        elevation: 0.0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            color: Colors.white),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50), topRight: Radius.circular(50)),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Matches(widget.currentUser, widget.newmatches),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Recent messages',
                    style: TextStyle(
                      color: _theme.backgroundColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                RecentChats(widget.currentUser, widget.matches),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
