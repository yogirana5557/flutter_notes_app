import 'package:flutter/material.dart';
import 'package:flutter_notes_app/services/sharedPref.dart';
import 'package:flutter_notes_app/utils/app_theme.dart';
import 'package:flutter_notes_app/views/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyApp> {
  ThemeData theme = themeData;

  @override
  void initState() {
    super.initState();
    updateThemeFromSharedPref();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: theme,
      home: MyHomePage(changeTheme: setTheme),
    );
  }

  setTheme(Brightness brightness) {
    if (brightness == Brightness.light) {
      setState(() {
        theme = themeData;
      });
    } else {
      setState(() {
        theme = themeDataDark;
      });
    }
  }

  updateThemeFromSharedPref() async {
    String themeText = await getThemeFromSharedPref();
    if (themeText == 'dark') {
      setTheme(Brightness.dark);
    } else {
      setTheme(Brightness.light);
    }
  }
}
