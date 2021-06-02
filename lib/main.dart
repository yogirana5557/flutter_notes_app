import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notes_app/isar.g.dart';
import 'package:flutter_notes_app/services/sharedPref.dart';
import 'package:flutter_notes_app/utils/app_theme.dart';
import 'package:flutter_notes_app/views/note_list.dart';
import 'package:isar/isar.dart';

import 'models/note.dart';

void main() async {
  final isar = await openIsar();
  runApp(MyApp(
    isar: isar,
  ));
}

class MyApp extends StatefulWidget {
  final Isar isar;

  MyApp({required this.isar});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyApp> {
  ThemeData theme = themeData;

  @override
  void initState() {
    super.initState();
    updateThemeFromSharedPref();
    setNotesFromDB();
  }

  setNotesFromDB() async {
    // var data = Note()
    //   ..title = 'Covid-19 vaccine registration for 18-44 age group'
    //   ..content =
    //       'Those in the age group of 18-44 years can register from April 28; the registrations have started from 4:00 pm onwards. You can log into the Co-WIN portal using the link http://www.cowin.gov.in and click on the “Register/Sign In yourself” tab to register for the COVID-19 vaccination. Alternatively, you can also register for vaccination through the Aarogya Setu App.'
    //   ..date = DateTime.now();
    //
    // widget.isar.writeTxn((isar) async {
    //   await isar.notes.put(data);
    // });

    // try {
    //   final bytes = await rootBundle.load('assets/quotes.json');
    //   widget.isar.writeTxn((isar) async {
    //     print("loading");
    //     await isar.notes.importJsonRaw(bytes.buffer.asUint8List());
    //     print("finished");
    //   });
    // } catch (e) {
    //   print(e);
    // }
  }

  Stream<List<Note>> execQuery() {
    return widget.isar.notes
        .where()
        .limit(1)
        .build()
        .watch(initialReturn: true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: theme,
      home: Scaffold(
        body: SafeArea(
          child: StreamBuilder(
            stream: execQuery(),
            builder: (context, AsyncSnapshot<List<Note>?> data) {
              if (data.hasData) {
                if (data.data!.isEmpty) {
                  return Text("No Notes");
                } else {
                  return QuotesList(
                    isar: widget.isar,
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
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
