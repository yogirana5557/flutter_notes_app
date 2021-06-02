import 'package:isar/isar.dart';

@Collection()
class Note {
  int? id;

  @Index(caseSensitive: false, indexType: IndexType.words)
  late String title;

  @Index(caseSensitive: false, indexType: IndexType.words)
  late String content;

  DateTime? date;
}
