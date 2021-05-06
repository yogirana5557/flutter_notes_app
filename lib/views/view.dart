import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/notes.dart';
import 'package:flutter_notes_app/services/database.dart';
import 'package:flutter_notes_app/views/edit.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

class ViewNotePage extends StatefulWidget {
  Function() triggerRefetch;
  Notes currentNote;

  ViewNotePage({Key key, Function() triggerRefetch, Notes currentNote})
      : super(key: key) {
    this.triggerRefetch = triggerRefetch;
    this.currentNote = currentNote;
  }

  @override
  _ViewNotePageState createState() => _ViewNotePageState();
}

class _ViewNotePageState extends State<ViewNotePage> {
  bool headerShouldShow = false;

  @override
  void initState() {
    super.initState();
    showHeader();
  }

  void showHeader() async {
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        headerShouldShow = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Container(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 24.0, right: 24.0, top: 40.0, bottom: 16),
                child: AnimatedOpacity(
                  opacity: headerShouldShow ? 1 : 0,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                  child: Text(
                    widget.currentNote.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                    ),
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: headerShouldShow ? 1 : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    DateFormat.yMd().add_jm().format(widget.currentNote.date),
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 24.0, top: 36, bottom: 24, right: 24),
                child: Text(
                  widget.currentNote.content,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 80,
                color: Theme.of(context).canvasColor.withOpacity(0.3),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_rounded),
                        onPressed: handleBack,
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded),
                        onPressed: handleDelete,
                      ),
                      IconButton(
                        icon: Icon(Icons.share_rounded),
                        onPressed: handleShare,
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_rounded),
                        onPressed: handleEdit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void handleEdit() {
    Navigator.pop(context);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => EditNotePage(
                  existingNote: widget.currentNote,
                  triggerRefetch: widget.triggerRefetch,
                )));
  }

  void handleShare() {
    Share.share(
        '${widget.currentNote.title.trim()}\n(On: ${widget.currentNote.date.toIso8601String().substring(0, 10)})\n\n${widget.currentNote.content}');
  }

  void handleBack() {
    Navigator.pop(context);
  }

  void handleDelete() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Delete Note'),
            content: Text('This note will be deleted permanently'),
            actions: <Widget>[
              TextButton(
                child: Text('DELETE'),
                onPressed: () async {
                  await NotesDatabaseService.db
                      .deleteNoteInDB(widget.currentNote);
                  widget.triggerRefetch();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              TextButton(
                style: TextButton.styleFrom(primary: Colors.grey),
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }
}
