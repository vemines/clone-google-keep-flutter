// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SharedNoteModelAdapter extends TypeAdapter<SharedNoteModel> {
  @override
  final int typeId = 5;

  @override
  SharedNoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SharedNoteModel(
      sharedNoteId: fields[0] as String?,
      noteId: fields[1] as String?,
      ownerId: fields[2] as String?,
      sharedUids: (fields[3] as List?)?.cast<String>(),
      permissions: (fields[4] as Map?)?.cast<String, bool>(),
      note: fields[5] as NoteModel?,
    );
  }

  @override
  void write(BinaryWriter writer, SharedNoteModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.sharedNoteId)
      ..writeByte(1)
      ..write(obj.noteId)
      ..writeByte(2)
      ..write(obj.ownerId)
      ..writeByte(3)
      ..write(obj.sharedUids)
      ..writeByte(4)
      ..write(obj.permissions)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharedNoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
