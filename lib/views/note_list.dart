import 'package:flutter/material.dart';
import 'package:flutter_notes_app/isar.g.dart';
import 'package:flutter_notes_app/models/note.dart';
import 'package:flutter_notes_app/views/widget/notes_card_widget.dart';
import 'package:isar/isar.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class QuotesList extends StatefulWidget {
  final Isar isar;

  QuotesList({required this.isar});

  @override
  _QuotesListState createState() => _QuotesListState();
}

class _QuotesListState extends State<QuotesList> {
  final searchController = TextEditingController();

  List<Note> quotes = [];
  bool hasMore = true;
  bool isLoading = true;
  String searchTerm = '';

  @override
  void initState() {
    loadMore();
    searchController.addListener(() {
      loadMore(newSearchTerm: searchController.text);
    });
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Query<Note> buildQuery({bool offsetLimit = false}) {
    final searchTermWords = searchTerm.split(RegExp(r'\s+'));
    return widget.isar.notes
        .where()
        .repeat(
          searchTermWords,
          (q, String word) => q.optional(
            word.isNotEmpty,
            (q) => q.titleWordStartsWith(word).or().contentWordStartsWith(word),
          ),
        )

        .optional(offsetLimit, (q) => q.offset(quotes.length).limit(20))
        .build();
  }

  void loadMore({String? newSearchTerm, String? newAuthor}) async {
    setState(() {
      isLoading = true;
      if (newSearchTerm != null) {
        quotes = [];
        searchTerm = newSearchTerm;
      }
    });

    final newQuotes = await buildQuery(offsetLimit: true).findAll();
    final newTotal = await buildQuery().count();

    setState(() {
      isLoading = false;
      quotes.addAll(newQuotes);
      hasMore = newTotal > quotes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
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
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        maxLines: 1,
                        autofocus: false,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
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
                          searchController.text.isEmpty
                              ? Icons.search_rounded
                              : Icons.cancel_rounded,
                          color: Colors.grey.shade400),
                      onPressed: () {
                        searchController.clear();
                      },
                    ),
                  ],
                ))),
        SizedBox(height: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: LazyLoadScrollView(
              onEndOfPage: () {
                if (hasMore) {
                  loadMore();
                }
              },
              isLoading: isLoading,
              scrollOffset: 300,
              child: ListView.builder(
                itemCount: quotes.length,
                itemBuilder: (context, index) {
                  return NotesCardWidget(
                    noteData: quotes[index],
                    onTapAction: (n) {},
                    searchTerm: searchController.text,
                  );
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}
