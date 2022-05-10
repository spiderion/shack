import 'package:flutter/material.dart';

class WelcomeTitleWidget extends StatelessWidget {
  const WelcomeTitleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return titleWidget();
  }

  Widget titleWidget() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Image.asset('assets/images/app_logo.png', height: 24),
            ),
            Container(
              child: Flexible(
                child: Text('The social dating movement',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center),
              ),
            )
          ],
        ),
      ),
    );
  }
}
