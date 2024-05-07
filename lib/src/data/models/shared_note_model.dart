import 'package:hive/hive.dart';

import 'note_model.dart';

part 'shared_note_model.g.dart';

@HiveType(typeId: 5)
class SharedNoteModel {
  @HiveField(0)
  final String? sharedNoteId;

  @HiveField(1)
  final String? noteId;

  @HiveField(2)
  final String? ownerId;

  @HiveField(3)
  final List<String>? sharedUids;

  @HiveField(4)
  final Map<String, bool>? permissions;

  @HiveField(5)
  final NoteModel? note;

  SharedNoteModel({
    this.sharedNoteId,
    this.noteId,
    this.ownerId,
    this.sharedUids,
    this.permissions,
    this.note,
  });

  factory SharedNoteModel.fromMap(Map<String, dynamic> data) => SharedNoteModel(
        sharedNoteId: data['sharedNoteId'] as String?,
        noteId: data['noteId'] as String?,
        ownerId: data['ownerId'] as String?,
        sharedUids: List<String>.from(data['sharedUids'] ?? []),
        permissions: data['permissions'] as Map<String, bool>?,
        note: data['note'] as NoteModel?,
      );

  Map<String, dynamic> toMap() => {
        'sharedNoteId': sharedNoteId,
        'noteId': noteId,
        'ownerId': ownerId,
        'sharedUids': sharedUids,
        'permissions': permissions,
      };
}
