import 'package:flutter/material.dart';
import 'package:flutter_notes_app/models/notes.dart';
import 'package:flutter_notes_app/utils/app_extensions.dart';
import 'package:intl/intl.dart';

class NotesCardWidget extends StatelessWidget {
  const NotesCardWidget({
    this.noteData,
    this.onTapAction,
    this.searchTerm = "",
    Key key,
  }) : super(key: key);

  final Notes noteData;
  final Function(Notes noteData) onTapAction;
  final String searchTerm;

  @override
  Widget build(BuildContext context) {
    String neatDate = DateFormat.yMd().add_jm().format(noteData.date);
    Color color = noteData.title.colorFromText();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 5,
            offset: Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            onTapAction(noteData);
          },
          splashColor: color.withAlpha(20),
          highlightColor: color.withAlpha(10),
          child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    maxLines: 2,
                    text: TextSpan(
                      children: highlightOccurrences(
                          noteData.title, searchTerm, false),
                      style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .headline6
                              .color,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 8),
                      child: RichText(
                        maxLines: 2,
                        text: TextSpan(
                          children: highlightOccurrences(
                              noteData.content, searchTerm, true),
                          style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .headline6
                                .color,
                          ),
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.only(top: 14),
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$neatDate',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ))
        ),
      ),
    );
  }

  List<TextSpan> highlightOccurrences(
      String source, String query, bool shouldWrap) {
    if (query == null || query.isEmpty) {
      return <TextSpan>[TextSpan(text: source)];
    }

    final List<Match> matches = <Match>[];
    for (final String token in query.trim().toLowerCase().split(' ')) {
      matches.addAll(token.allMatches(source.toLowerCase()));
    }

    if (matches.isEmpty) {
      return <TextSpan>[TextSpan(text: source)];
    }
    matches.sort((Match a, Match b) => a.start.compareTo(b.start));
    int lastMatchEnd = 0;
    final List<TextSpan> children = <TextSpan>[];
    const Color matchColor = Colors.red;
    for (final Match match in matches) {
      print("start ${match.start} \t end ${match.end}");
      if (match.end <= lastMatchEnd) {
        // already matched -> ignore
      } else if (match.start <= lastMatchEnd) {
        children.add(TextSpan(
          text: source.substring(lastMatchEnd, match.end),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: matchColor,
          ),
        ));
      } else {
        if (shouldWrap) {
          if (match.start > matches[0].start) {
            children.add(TextSpan(
              text: source.substring(lastMatchEnd, match.start),
            ));
          } else {
            children.add(TextSpan(
              text: "...",
            ));
          }
        } else {
          children.add(TextSpan(
            text: source.substring(lastMatchEnd, match.start),
          ));
        }

        children.add(TextSpan(
          text: source.substring(match.start, match.end),
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: matchColor),
        ));
      }

      if (lastMatchEnd < match.end) {
        lastMatchEnd = match.end;
      }
    }

    if (lastMatchEnd < source.length) {
      children.add(TextSpan(
        text: source.substring(lastMatchEnd, source.length),
      ));
    }

    return children;
  }
}
