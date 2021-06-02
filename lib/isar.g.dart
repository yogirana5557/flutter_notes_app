// ignore_for_file: unused_import, implementation_imports

import 'dart:ffi';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:isar/src/isar_native.dart';
import 'package:isar/src/query_builder.dart';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'models/note.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/widgets.dart';

const _utf8Encoder = Utf8Encoder();

final _schema =
    '[{"name":"Note","idProperty":"id","properties":[{"name":"id","type":3},{"name":"title","type":5},{"name":"content","type":5}],"indexes":[{"unique":false,"replace":false,"properties":[{"name":"title","indexType":2,"caseSensitive":false}]},{"unique":false,"replace":false,"properties":[{"name":"content","indexType":2,"caseSensitive":false}]}],"links":[]}]';

Future<Isar> openIsar(
    {String name = 'isar',
    String? directory,
    int maxSize = 1000000000,
    Uint8List? encryptionKey}) async {
  final path = await _preparePath(directory);
  return openIsarInternal(
      name: name,
      directory: path,
      maxSize: maxSize,
      encryptionKey: encryptionKey,
      schema: _schema,
      getCollections: (isar) {
        final collectionPtrPtr = malloc<Pointer>();
        final propertyOffsetsPtr = malloc<Uint32>(3);
        final propertyOffsets = propertyOffsetsPtr.asTypedList(3);
        final collections = <String, IsarCollection>{};
        nCall(IC.isar_get_collection(isar.ptr, collectionPtrPtr, 0));
        IC.isar_get_property_offsets(
            collectionPtrPtr.value, propertyOffsetsPtr);
        collections['Note'] = IsarCollectionImpl<Note>(
          isar: isar,
          adapter: _NoteAdapter(),
          ptr: collectionPtrPtr.value,
          propertyOffsets: propertyOffsets.sublist(0, 3),
          propertyIds: {'id': 0, 'title': 1, 'content': 2},
          indexIds: {'title': 0, 'content': 1},
          linkIds: {},
          backlinkIds: {},
          getId: (obj) => obj.id,
          setId: (obj, id) => obj.id = id,
        );
        malloc.free(propertyOffsetsPtr);
        malloc.free(collectionPtrPtr);

        return collections;
      });
}

Future<String> _preparePath(String? path) async {
  if (path == null || p.isRelative(path)) {
    WidgetsFlutterBinding.ensureInitialized();
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, path ?? 'isar');
  } else {
    return path;
  }
}

class _NoteAdapter extends TypeAdapter<Note> {
  @override
  int serialize(IsarCollectionImpl<Note> collection, RawObject rawObj,
      Note object, List<int> offsets,
      [int? existingBufferSize]) {
    var dynamicSize = 0;
    final value0 = object.id;
    final _id = value0;
    final value1 = object.title;
    final _title = _utf8Encoder.convert(value1);
    dynamicSize += _title.length;
    final value2 = object.content;
    final _content = _utf8Encoder.convert(value2);
    dynamicSize += _content.length;
    final size = dynamicSize + 26;

    late int bufferSize;
    if (existingBufferSize != null) {
      if (existingBufferSize < size) {
        malloc.free(rawObj.buffer);
        rawObj.buffer = malloc(size);
        bufferSize = size;
      } else {
        bufferSize = existingBufferSize;
      }
    } else {
      rawObj.buffer = malloc(size);
      bufferSize = size;
    }
    rawObj.buffer_length = size;
    final buffer = rawObj.buffer.asTypedList(size);
    final writer = BinaryWriter(buffer, 26);
    writer.writeLong(offsets[0], _id);
    writer.writeBytes(offsets[1], _title);
    writer.writeBytes(offsets[2], _content);
    return bufferSize;
  }

  @override
  Note deserialize(IsarCollectionImpl<Note> collection, BinaryReader reader,
      List<int> offsets) {
    final object = Note();
    object.id = reader.readLongOrNull(offsets[0]);
    object.title = reader.readString(offsets[1]);
    object.content = reader.readString(offsets[2]);
    return object;
  }

  @override
  P deserializeProperty<P>(BinaryReader reader, int propertyIndex, int offset) {
    switch (propertyIndex) {
      case 0:
        return (reader.readLongOrNull(offset)) as P;
      case 1:
        return (reader.readString(offset)) as P;
      case 2:
        return (reader.readString(offset)) as P;
      default:
        throw 'Illegal propertyIndex';
    }
  }
}

extension GetCollection on Isar {
  IsarCollection<Note> get notes {
    return getCollection('Note');
  }
}

extension NoteQueryWhereSort on QueryBuilder<Note, QWhere> {
  QueryBuilder<Note, QAfterWhere> anyId() {
    return addWhereClause(WhereClause(indexName: 'id'));
  }
}

extension NoteQueryWhere on QueryBuilder<Note, QWhereClause> {
  QueryBuilder<Note, QAfterWhereClause> titleWordEqualTo(String title) {
    return addWhereClause(WhereClause(
      indexName: 'title',
      upper: [title],
      includeUpper: true,
      lower: [title],
      includeLower: true,
    ));
  }

  QueryBuilder<Note, QAfterWhereClause> titleWordStartsWith(String value) {
    final convertedValue = value;
    return addWhereClause(WhereClause(
      indexName: 'title',
      lower: [convertedValue],
      upper: ['$convertedValue\u{FFFFF}'],
      includeLower: true,
      includeUpper: true,
    ));
  }

  QueryBuilder<Note, QAfterWhereClause> contentWordEqualTo(String content) {
    return addWhereClause(WhereClause(
      indexName: 'content',
      upper: [content],
      includeUpper: true,
      lower: [content],
      includeLower: true,
    ));
  }

  QueryBuilder<Note, QAfterWhereClause> contentWordStartsWith(String value) {
    final convertedValue = value;
    return addWhereClause(WhereClause(
      indexName: 'content',
      lower: [convertedValue],
      upper: ['$convertedValue\u{FFFFF}'],
      includeLower: true,
      includeUpper: true,
    ));
  }
}

extension NoteQueryFilter on QueryBuilder<Note, QFilterCondition> {
  QueryBuilder<Note, QAfterFilterCondition> idIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<Note, QAfterFilterCondition> idEqualTo(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Note, QAfterFilterCondition> idGreaterThan(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Note, QAfterFilterCondition> idLessThan(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Note, QAfterFilterCondition> idBetween(int? lower, int? upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'id',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Note, QAfterFilterCondition> titleEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'title',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Note, QAfterFilterCondition> titleStartsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'title',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Note, QAfterFilterCondition> titleEndsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'title',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Note, QAfterFilterCondition> titleContains(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'title',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Note, QAfterFilterCondition> titleMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'title',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Note, QAfterFilterCondition> contentEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'content',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Note, QAfterFilterCondition> contentStartsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'content',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Note, QAfterFilterCondition> contentEndsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'content',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Note, QAfterFilterCondition> contentContains(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'content',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Note, QAfterFilterCondition> contentMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'content',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }
}

extension NoteQueryLinks on QueryBuilder<Note, QFilterCondition> {}

extension NoteQueryWhereSortBy on QueryBuilder<Note, QSortBy> {
  QueryBuilder<Note, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.Asc);
  }

  QueryBuilder<Note, QAfterSortBy> sortByIdDesc() {
    return addSortByInternal('id', Sort.Desc);
  }

  QueryBuilder<Note, QAfterSortBy> sortByTitle() {
    return addSortByInternal('title', Sort.Asc);
  }

  QueryBuilder<Note, QAfterSortBy> sortByTitleDesc() {
    return addSortByInternal('title', Sort.Desc);
  }

  QueryBuilder<Note, QAfterSortBy> sortByContent() {
    return addSortByInternal('content', Sort.Asc);
  }

  QueryBuilder<Note, QAfterSortBy> sortByContentDesc() {
    return addSortByInternal('content', Sort.Desc);
  }
}

extension NoteQueryWhereSortThenBy on QueryBuilder<Note, QSortThenBy> {
  QueryBuilder<Note, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.Asc);
  }

  QueryBuilder<Note, QAfterSortBy> thenByIdDesc() {
    return addSortByInternal('id', Sort.Desc);
  }

  QueryBuilder<Note, QAfterSortBy> thenByTitle() {
    return addSortByInternal('title', Sort.Asc);
  }

  QueryBuilder<Note, QAfterSortBy> thenByTitleDesc() {
    return addSortByInternal('title', Sort.Desc);
  }

  QueryBuilder<Note, QAfterSortBy> thenByContent() {
    return addSortByInternal('content', Sort.Asc);
  }

  QueryBuilder<Note, QAfterSortBy> thenByContentDesc() {
    return addSortByInternal('content', Sort.Desc);
  }
}

extension NoteQueryWhereDistinct on QueryBuilder<Note, QDistinct> {
  QueryBuilder<Note, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<Note, QDistinct> distinctByTitle({bool caseSensitive = true}) {
    return addDistinctByInternal('title', caseSensitive: caseSensitive);
  }

  QueryBuilder<Note, QDistinct> distinctByContent({bool caseSensitive = true}) {
    return addDistinctByInternal('content', caseSensitive: caseSensitive);
  }
}

extension NoteQueryProperty on QueryBuilder<Note, QQueryProperty> {
  QueryBuilder<int?, QQueryOperations> idProperty() {
    return addPropertyName('id');
  }

  QueryBuilder<String, QQueryOperations> titleProperty() {
    return addPropertyName('title');
  }

  QueryBuilder<String, QQueryOperations> contentProperty() {
    return addPropertyName('content');
  }
}
