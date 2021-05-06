import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/notes.dart';
import 'package:flutter_notes_app/services/database.dart';
import 'package:flutter_notes_app/services/sharedPref.dart';
import 'package:flutter_notes_app/utils/fade_route.dart';
import 'package:flutter_notes_app/views/edit.dart';
import 'package:flutter_notes_app/views/view.dart';
import 'package:flutter_notes_app/views/widget/notes_card_widget.dart';

class MyHomePage extends StatefulWidget {
  Function(Brightness brightness) changeTheme;

  MyHomePage({Key key, Function(Brightness brightness) changeTheme})
      : super(key: key) {
    this.changeTheme = changeTheme;
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Notes> notesList = [];
  bool headerShouldHide = false;
  bool isSearchEmpty = true;
  TextEditingController searchController = TextEditingController();
  String selectedTheme;

  @override
  void initState() {
    super.initState();
    NotesDatabaseService.db.init();
    setNotesFromDB();
  }

  setNotesFromDB() async {
    print("Entered setNotes");
    // for (var i = 0; i < 10; i++) {
    //   await NotesDatabaseService.db.addNoteInDB(Notes(
    //       title: 'Covid-19 vaccine registration for 18-44 age group $i',
    //       content:
    //           'Those in the age group of 18-44 years can register from April 28; the registrations have started from 4:00 pm onwards. You can log into the Co-WIN portal using the link http://www.cowin.gov.in and click on the “Register/Sign In yourself” tab to register for the COVID-19 vaccination. Alternatively, you can also register for vaccination through the Aarogya Setu App.',
    //       date: DateTime.now()));
    // }

    var fetchedNotes = await NotesDatabaseService.db.getNotesFromDB();
    setState(() {
      notesList = fetchedNotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      if (Theme.of(context).brightness == Brightness.dark) {
        selectedTheme = 'dark';
      } else {
        selectedTheme = 'light';
      }
    });
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          gotoEditNote();
        },
        label: Text('Add note'.toUpperCase()),
        icon: Icon(Icons.add_rounded),
      ),
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  buildHeaderWidget(context),
                  buildButtonRow(context),
                  SizedBox(height: 32),
                  ...buildNoteComponentsList(),
                ],
              ))),
    );
  }

  Widget buildHeaderWidget(BuildContext context) {
    return Row(
      children: <Widget>[
        AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            width: headerShouldHide ? 0 : 200,
            child: Text(
              'Your Notes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              overflow: TextOverflow.clip,
              softWrap: false,
            )),
        Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            var value = (Theme.of(context).brightness == Brightness.dark)
                ? "light"
                : "dark";
            setState(() {
              selectedTheme = value;
            });
            if (value == 'light') {
              widget.changeTheme(Brightness.light);
            } else {
              widget.changeTheme(Brightness.dark);
            }
            setThemeinSharedPref(value);
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.all(16),
            alignment: Alignment.centerRight,
            child: Icon(selectedTheme == "dark"
                ? Icons.wb_sunny_outlined
                : Icons.nights_stay_outlined),
          ),
        ),
      ],
    );
  }

  Widget buildButtonRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.only(left: 16),
        height: 50,
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.all(Radius.circular(16))),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: searchController,
                maxLines: 1,
                onChanged: (value) {
                  handleSearch(value);
                },
                autofocus: false,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration.collapsed(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                  isSearchEmpty ? Icons.search_rounded : Icons.cancel_rounded,
                  color: Colors.grey.shade400),
              onPressed: cancelSearch,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildNoteComponentsList() {
    List<Widget> noteComponentsList = [];
    notesList.sort((a, b) {
      return b.date.compareTo(a.date);
    });
    if (searchController.text.isNotEmpty) {
      notesList.forEach((note) {
        if (note.title
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            note.content
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
          noteComponentsList.add(NotesCardWidget(
            noteData: note,
            onTapAction: openNoteToRead,
            searchTerm: searchController.text,
          ));
      });
      return noteComponentsList;
    }

    notesList.forEach((note) {
      noteComponentsList.add(NotesCardWidget(
        noteData: note,
        onTapAction: openNoteToRead,
      ));
    });

    return noteComponentsList;
  }

  void handleSearch(String value) {
    if (value.isNotEmpty) {
      setState(() {
        isSearchEmpty = false;
      });
    } else {
      setState(() {
        isSearchEmpty = true;
      });
    }
  }

  void gotoEditNote() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) =>
                EditNotePage(triggerRefetch: refetchNotesFromDB)));
  }

  void refetchNotesFromDB() async {
    await setNotesFromDB();
    print("Refetched notes");
  }

  openNoteToRead(Notes noteData) async {
    setState(() {
      headerShouldHide = true;
    });
    await Future.delayed(Duration(milliseconds: 230), () {});
    Navigator.push(
        context,
        FadeRoute(
            page: ViewNotePage(
                triggerRefetch: refetchNotesFromDB, currentNote: noteData)));
    await Future.delayed(Duration(milliseconds: 300), () {});

    setState(() {
      headerShouldHide = false;
    });
  }

  void cancelSearch() {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      searchController.clear();
      isSearchEmpty = true;
    });
  }
}
