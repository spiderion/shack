import 'package:flutter/material.dart';

class WelcomeBackgroundWidget extends StatelessWidget {
  const WelcomeBackgroundWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return background(MediaQuery.of(context), Theme.of(context));
  }

  Widget background(MediaQueryData mediaQueryData, ThemeData _theme) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/images/splash_screen.jpg"), fit: BoxFit.cover),
          color: Colors.white),
      padding: EdgeInsets.only(top: mediaQueryData.padding.top),
    );
  }
}
