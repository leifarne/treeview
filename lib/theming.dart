import 'package:flutter/material.dart';

ThemeData buildCloudThemeIndigo3() {
  return ThemeData(
    primarySwatch: Colors.indigo,
    primaryColor: Colors.indigo.shade800,
    primaryColorDark: Color(0xff001064),
    primaryColorLight: Color(0xff5f5fc4),
    accentColor: Colors.cyan.shade900,
    buttonColor: Colors.cyan.shade900,
  );
}

TextButtonThemeData buildFrontPageTextButtonThemeData() {
  return TextButtonThemeData(
      style: ButtonStyle(
    // backgroundColor: ButtonBackgroundColor(Colors.orange.shade400),
    overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
    foregroundColor: MaterialStateProperty.all(Colors.white),
    // fixedSize: MaterialStateProperty.all(Size(80, 30)),
  ));
}

ElevatedButtonThemeData buildFrontPageElevatedButtonThemeData() {
  return ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: ButtonBackgroundColor(Colors.orange.shade400),
      foregroundColor: MaterialStateProperty.all(Colors.black),
      textStyle: MaterialStateProperty.all(TextStyle(fontWeight: FontWeight.bold)),
    ),
    // appBarTheme: AppBarTheme(backgroundColor: Colors.indigo.shade100),
    // tabBarTheme: TabBarTheme(labelStyle: TextStyle(backgroundColor: Colors.red)),
  );
}

class ButtonBackgroundColor extends MaterialStateColor {
  ButtonBackgroundColor(Color defaultColor) : super(defaultColor.value);

  @override
  Color resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.hovered)) {
      return Color(value).withOpacity(0.7);
    }
    return Color(value);
  }
}
