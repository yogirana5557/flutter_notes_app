import 'package:flutter/material.dart';

final ThemeData themeData = ThemeData(
  fontFamily: 'Montserrat',
  visualDensity: VisualDensity.adaptivePlatformDensity,
  brightness: Brightness.light,
  primaryColorBrightness: Brightness.light,
  accentColorBrightness: Brightness.light,
  primarySwatch: Colors.red,
  primaryColor: Colors.red,
  accentColor: Colors.red,
  scaffoldBackgroundColor: Color(0xffFBFAFF),
  backgroundColor: Color(0xffFBFAFF),
  iconTheme: IconThemeData(color: Colors.black87),
);

final ThemeData themeDataDark = ThemeData(
  fontFamily: 'Montserrat',
  visualDensity: VisualDensity.adaptivePlatformDensity,
  brightness: Brightness.dark,
  primaryColorBrightness: Brightness.dark,
  accentColorBrightness: Brightness.dark,
  primarySwatch: Colors.red,
  primaryColor: Colors.red,
  accentColor: Colors.red,
  scaffoldBackgroundColor: Color(0xff181618),
  backgroundColor: Color(0xff181618),
  iconTheme: IconThemeData(color: Colors.white),
  cardColor: Color(0xff212021),
);
