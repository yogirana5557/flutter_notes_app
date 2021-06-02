class Notes {
  int? id;
  String? title;
  String? content;
  DateTime? date;

  Notes({this.id, this.title, this.content, this.date});

  Notes.fromMap(Map<String, dynamic> map) {
    this.id = map['_id'];
    this.title = map['title'];
    this.content = map['content'];
    this.date = DateTime.parse(map['date']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': this.id,
      'title': this.title,
      'content': this.content,
      'date': this.date?.toIso8601String()
    };
  }
}
