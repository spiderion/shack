import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin{

  bool isLoading = true;
  bool isAuth = false;
  bool isRegistered = false;

  AnimationController _controller;
  Animation _textAimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _textAimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Listen to animation completion
    _controller.addStatusListener(handler);

    // Starts the animation
    _controller.forward();

  }

  @override
  void dispose() {
    // Very Important to dispose the controller for optimization.
    _controller.removeStatusListener(handler);
    _controller?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
      backgroundColor: _theme.backgroundColor,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: _theme.backgroundColor,
          child: Center(
            child: FadeTransition(
              opacity: _textAimation,
              child: Text(
                'THE GRID',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 40,
                  color: _theme.primaryColor
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        )
    );
  }
  Future<void> handler(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      log('Animation complete', name: 'Splash screen');

    }
  }
}
