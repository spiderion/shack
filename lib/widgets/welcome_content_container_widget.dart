import 'package:flutter/material.dart';

class WelcomeContentContainerWidget extends StatelessWidget {
  final Widget child;

  const WelcomeContentContainerWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return signUpActions(context);
  }

  Widget signUpActions(BuildContext context) {
    return SafeArea(
      child: Container(
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(top: 100, right: 12, left: 12, bottom: 12),
          decoration:
              BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.0))),
          padding: EdgeInsets.all(30),
          child: Align(alignment: Alignment.center, child: child)),
    );
  }
}
