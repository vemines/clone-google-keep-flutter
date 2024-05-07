import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:keep_app/src/shared/shared.dart';

import 'image_model.dart';
import 'record_model.dart';
import "remind_model.dart";
import 'todo_model.dart';

part "content_style_model.dart";
part 'note_model.g.dart';

enum BgNote { none, bgNote1, bgNote2, bgNote3 }

String? bgNoteAssets(BgNote bgnote) {
  switch (bgnote) {
    case BgNote.bgNote1:
      return Assets.jpg.bg1.path;
    case BgNote.bgNote2:
      return Assets.jpg.bg2.path;
    case BgNote.bgNote3:
      return Assets.jpg.bg3.path;
    default:
      return null;
  }
}

Color? bgNoteColor(BgColor bgColor) {
  switch (bgColor) {
    case BgColor.red:
      return Colors.red[300];
    case BgColor.orange:
      return Colors.orange[300];
    case BgColor.brown:
      return Colors.brown[300];
    case BgColor.green:
      return Colors.green[300];
    case BgColor.purple:
      return Colors.purple[300];
    default:
      return null;
  }
}

enum BgColor { none, red, orange, brown, green, purple }

@HiveType(typeId: 1)
class NoteModel {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? title;

  @HiveField(2)
  String? content;

  @HiveField(3)
  List<TodoModel>? todos;

  @HiveField(4)
  List<RecordModel>? records;

  @HiveField(5)
  RemindModel? remind;

  @HiveField(6)
  CustomRemindEvent? customRemind;

  @HiveField(7)
  List<String>? labelIds;

  @HiveField(8)
  List<ImageModel>? imageUrls;

  @HiveField(9)
  bool pinned;

  @HiveField(10)
  bool archived;

  @HiveField(11)
  bool trashed;

  @HiveField(12)
  Map<int, ContentStyleByWord>? contentStyleWords;

  @HiveField(13)
  Map<int, ContentStyleByLine>? contentStyleLines;

  @HiveField(14)
  DateTime? lastModified;

  @HiveField(15)
  DateTime? createAt;

  @HiveField(16)
  DateTime? deleteAt;

  @HiveField(17)
  int bgColor;

  @HiveField(18)
  int bgNote;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoteModel && id == other.id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  NoteModel({
    this.id,
    this.title = "",
    this.content = "",
    this.todos,
    this.records,
    this.remind,
    this.customRemind,
    this.labelIds,
    this.imageUrls,
    this.pinned = false,
    this.archived = false,
    this.trashed = false,
    this.contentStyleWords,
    this.contentStyleLines,
    this.lastModified,
    this.createAt,
    this.bgColor = 0,
    this.bgNote = 0,
  });

  factory NoteModel.fromMap(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      todos: (json['todos'] as List<dynamic>?)
          ?.map((todo) => TodoModel.fromMap(todo))
          .toList(),
      records: (json['records'] as List<dynamic>?)
          ?.map((record) => RecordModel.fromMap(record))
          .toList(),
      remind:
          json['remind'] == null ? null : RemindModel.fromMap(json['remind']),
      labelIds: (json['tagLabels'] as List<dynamic>?)
          ?.map((label) => label.toString())
          .toList(),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((image) => ImageModel.fromMap(image))
          .toList(),
      pinned: json['pinned'] as bool? ?? false,
      archived: json['archived'] as bool? ?? false,
      trashed: json['trashed'] as bool? ?? false,
      contentStyleWords:
          json['contentStyleWords'] as Map<int, ContentStyleByWord>?,
      contentStyleLines:
          json['contentStyleLines'] as Map<int, ContentStyleByLine>?,
      lastModified: json['lastModified'] != null
          ? (json['lastModified'] as Timestamp).toDate()
          : null,
      createAt: json['createAt'] != null
          ? (json['createAt'] as Timestamp).toDate()
          : null,
      bgColor: json['bgColor'] as int? ?? 0,
      bgNote: json['bgNote'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'todos': todos?.map((todo) => todo.toMap()).toList(),
        'records': records?.map((record) => record.toMap()).toList(),
        'remind': remind,
        'tagLabels': labelIds?.toList(),
        'imageUrls': imageUrls?.map((image) => image.toMap()).toList(),
        'pinned': pinned,
        'archived': archived,
        'trashed': trashed,
        'contentStyleWords': contentStyleWords,
        'contentStyleLines': contentStyleLines,
        'bgColor': bgColor,
        'bgNote': bgNote,
      };

  bool isEmptyNote() {
    return title == "" &&
        content == "" &&
        todos == null &&
        records == null &&
        remind == null &&
        labelIds == null &&
        imageUrls == null;
  }
}
