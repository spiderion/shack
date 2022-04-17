// Copyright (c) 2020 Aniket Malik [aniketmalikwork@gmail.com]
// All Rights Reserved.
//
// NOTICE: All information contained herein is, and remains the
// property of Aniket Malik. The intellectual and technical concepts
// contained herein are proprietary to Aniket Malik and are protected
// by trade secret or copyright law.
//
// Dissemination of this information or reproduction of this material
// is strictly forbidden unless prior written permission is obtained from
// Aniket Malik.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shack/themes/themeGuide.dart';

abstract class CustomeTheme {
  // Error Color common to both Themes
  static const Color _errorColor = Colors.red;

  // Button Theme
  static const ButtonThemeData _buttonTheme = ButtonThemeData(
    buttonColor: LightTheme.mRed,
    disabledColor: LightTheme.mDisabledColor,
    padding: EdgeInsets.symmetric(vertical: 5),
    materialTapTargetSize: MaterialTapTargetSize.padded,
    shape: RoundedRectangleBorder(
      borderRadius: ThemeGuide.borderRadius10,
    ),
  );

  // Contains the information about the light theme
  static ThemeData lightTheme = ThemeData().copyWith(
    highlightColor: const Color.fromRGBO(251, 186, 123, 0.2),
    splashColor: primaryColor,
    accentColor: primaryColor,
    hintColor: Colors.black26,
    cursorColor: Colors.black,
    primaryColor: primaryColor,
    primaryColorLight: LightTheme.mRed,
    dialogBackgroundColor: Colors.white,
    brightness: Brightness.light,
    primaryColorDark: LightTheme.mPurple,
    buttonTheme: _buttonTheme,
    errorColor: _errorColor,
    backgroundColor: Colors.white,
    inputDecorationTheme: LightTheme.inputDecorationTheme,
    primaryIconTheme: LightTheme.mIconThemeData,
    appBarTheme: LightTheme.appBarTheme,
    disabledColor: const Color.fromRGBO(200, 200, 200, 1),
  );
}

abstract class LightTheme {
  static const Color mRed = Color(0xFFF58474);
  static const Color mPurple = Color(0xFF2B2E51);
  static const Color mLightPurple = Color(0xFF5F5186);
  static const Color mYellow = Color(0xFFF1AC71);
  static const Color mBlue = Color(0xFF93B4DF);
  static const Color mDisabledColor = Colors.black26;
  static const IconThemeData mIconThemeData = IconThemeData(color: Colors.black);
  static const InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: Color.fromRGBO(240, 240, 240, 1),
    border: InputBorder.none,
    hintStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
    ),
    prefixStyle: TextStyle(
      color: Colors.black54,
    ),
  );
  static AppBarTheme appBarTheme = AppBarTheme(
    color: Colors.white,
    elevation: 0.0,
    textTheme: TextTheme(
      headline6: TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
    ),
    brightness: Platform.isIOS ? Brightness.light : Brightness.dark,
  );
}

Color primaryColor = Color(0xffF95797);
Color secondryColor = Colors.white;
Color darkPrimaryColor = Color(0x22ff3a5a);
Color textColor = Colors.black;