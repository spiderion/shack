import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shack/screens/allow_location.dart';
import 'package:shack/screens/util/custom_snackbar.dart';

class ShowGender extends StatefulWidget {
  final Map<String, dynamic> userData;

  ShowGender(this.userData);

  @override
  _ShowGenderState createState() => _ShowGenderState();
}

class _ShowGenderState extends State<ShowGender> {
  bool man = false;
  bool woman = false;
  bool eyeryone = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
        key: _scaffoldKey,
        appBar: appBar(context),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            options(_theme, context),
            man || woman || eyeryone ? buttonContinue(context) : continueSecond(context, _theme)
          ],
        ));
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop()),
        title: Text("Show me", style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
        centerTitle: true);
  }

  Widget continueSecond(BuildContext context, ThemeData _theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: InkWell(
          child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(25),
              ),
              height: MediaQuery.of(context).size.height * .065,
              width: MediaQuery.of(context).size.width * .75,
              child: Center(
                  child: Text(
                "CONTINUE",
                style: TextStyle(
                    fontSize: 15, color: _theme.colorScheme.onSecondary, fontWeight: FontWeight.bold),
              ))),
          onTap: () {
            CustomSnackbar.snackbar("Please select one", _scaffoldKey);
          },
        ),
      ),
    );
  }

  Container buttonContinue(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.only(top: 10, bottom: 10, left: 25, right: 25),
      child: ElevatedButton(
          onPressed: () {
            if (man) {
              widget.userData.addAll({'showGender': "man"});
            } else if (woman) {
              widget.userData.addAll({'showGender': "woman"});
            } else {
              widget.userData.addAll({'showGender': "everyone"});
            }

            print(widget.userData);
            Navigator.push(context, CupertinoPageRoute(builder: (context) => AllowLocation(widget.userData)));
          },
          child: Container(
            alignment: Alignment.center,
            child: Text(
              'CONTINUE',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          )),
    );
  }

  Container options(ThemeData _theme, BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          option("MEN", man, () {
            setState(() {
              woman = false;
              man = true;
              eyeryone = false;
            });
          }),
          option("WOMEN", woman, () {
            setState(() {
              woman = true;
              man = false;
              eyeryone = false;
            });
          }),
          option("EVERYONE", eyeryone, () {
            setState(() {
              woman = false;
              man = false;
              eyeryone = true;
            });
          }),
        ],
      ),
    );
  }

  Widget option(String text, bool isSelected, Function() onTap) {
    final _theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
        child: Container(
          height: MediaQuery.of(context).size.height * .065,
          width: MediaQuery.of(context).size.width * .75,
          child: Center(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 20,
                      color: isSelected ? _theme.primaryColor : _theme.colorScheme.onSecondary,
                      fontWeight: FontWeight.bold))),
        ),
        onPressed: onTap,
      ),
    );
  }
}
