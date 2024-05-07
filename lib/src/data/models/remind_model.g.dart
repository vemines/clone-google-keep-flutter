// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remind_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RemindModelAdapter extends TypeAdapter<RemindModel> {
  @override
  final int typeId = 3;

  @override
  RemindModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RemindModel(
      date: fields[0] as DateTime?,
      repeatType: fields[1] as RepeatType?,
      customRemindEvent: fields[2] as CustomRemindEvent?,
      markAsDone: fields[3] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, RemindModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.repeatType)
      ..writeByte(2)
      ..write(obj.customRemindEvent)
      ..writeByte(3)
      ..write(obj.markAsDone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemindModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CustomRemindEventAdapter extends TypeAdapter<CustomRemindEvent> {
  @override
  final int typeId = 2;

  @override
  CustomRemindEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomRemindEvent(
      everyNDay: fields[0] as int,
      forever: fields[1] as bool?,
      until: fields[2] as bool?,
      untilDate: fields[3] as DateTime?,
      forRepeat: fields[4] as bool?,
      forRepeatTime: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomRemindEvent obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.everyNDay)
      ..writeByte(1)
      ..write(obj.forever)
      ..writeByte(2)
      ..write(obj.until)
      ..writeByte(3)
      ..write(obj.untilDate)
      ..writeByte(4)
      ..write(obj.forRepeat)
      ..writeByte(5)
      ..write(obj.forRepeatTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomRemindEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
