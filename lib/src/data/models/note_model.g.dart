// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 1;

  @override
  NoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteModel(
      id: fields[0] as String?,
      title: fields[1] as String?,
      content: fields[2] as String?,
      todos: (fields[3] as List?)?.cast<TodoModel>(),
      records: (fields[4] as List?)?.cast<RecordModel>(),
      remind: fields[5] as RemindModel?,
      customRemind: fields[6] as CustomRemindEvent?,
      labelIds: (fields[7] as List?)?.cast<String>(),
      imageUrls: (fields[8] as List?)?.cast<ImageModel>(),
      pinned: fields[9] as bool,
      archived: fields[10] as bool,
      trashed: fields[11] as bool,
      contentStyleWords: (fields[12] as Map?)?.cast<int, ContentStyleByWord>(),
      contentStyleLines: (fields[13] as Map?)?.cast<int, ContentStyleByLine>(),
      lastModified: fields[14] as DateTime?,
      createAt: fields[15] as DateTime?,
      bgColor: fields[17] as int,
      bgNote: fields[18] as int,
    )..deleteAt = fields[16] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.todos)
      ..writeByte(4)
      ..write(obj.records)
      ..writeByte(5)
      ..write(obj.remind)
      ..writeByte(6)
      ..write(obj.customRemind)
      ..writeByte(7)
      ..write(obj.labelIds)
      ..writeByte(8)
      ..write(obj.imageUrls)
      ..writeByte(9)
      ..write(obj.pinned)
      ..writeByte(10)
      ..write(obj.archived)
      ..writeByte(11)
      ..write(obj.trashed)
      ..writeByte(12)
      ..write(obj.contentStyleWords)
      ..writeByte(13)
      ..write(obj.contentStyleLines)
      ..writeByte(14)
      ..write(obj.lastModified)
      ..writeByte(15)
      ..write(obj.createAt)
      ..writeByte(16)
      ..write(obj.deleteAt)
      ..writeByte(17)
      ..write(obj.bgColor)
      ..writeByte(18)
      ..write(obj.bgNote);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
