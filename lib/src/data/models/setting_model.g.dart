// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 4;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      addNoteToBottom: fields[0] as bool,
      moveCheckedToBottom: fields[1] as bool,
      displayRichLink: fields[2] as bool,
      theme: fields[3] as String,
      morningRemind: fields[4] as String,
      afternoonRemind: fields[5] as String,
      eveningRemind: fields[6] as String,
      enableSharing: fields[7] as bool,
      language: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.addNoteToBottom)
      ..writeByte(1)
      ..write(obj.moveCheckedToBottom)
      ..writeByte(2)
      ..write(obj.displayRichLink)
      ..writeByte(3)
      ..write(obj.theme)
      ..writeByte(4)
      ..write(obj.morningRemind)
      ..writeByte(5)
      ..write(obj.afternoonRemind)
      ..writeByte(6)
      ..write(obj.eveningRemind)
      ..writeByte(7)
      ..write(obj.enableSharing)
      ..writeByte(8)
      ..write(obj.language);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
