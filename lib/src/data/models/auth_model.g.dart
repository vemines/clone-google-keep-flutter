// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthModelAdapter extends TypeAdapter<AuthModel> {
  @override
  final int typeId = 7;

  @override
  AuthModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthModel(
      uid: fields[0] as String?,
      displayName: fields[1] as String?,
      imageUrl: fields[2] as String?,
      email: fields[3] as String?,
      provider: fields[4] as String?,
      settings: fields[5] as SettingsModel?,
      notesId: (fields[6] as List?)?.cast<String>(),
      sharedNotesId: (fields[7] as List?)?.cast<String>(),
      lastSignInTime: fields[9] as DateTime?,
      createAt: fields[8] as DateTime?,
      labels: (fields[10] as List?)?.cast<LabelModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, AuthModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.provider)
      ..writeByte(5)
      ..write(obj.settings)
      ..writeByte(6)
      ..write(obj.notesId)
      ..writeByte(7)
      ..write(obj.sharedNotesId)
      ..writeByte(8)
      ..write(obj.createAt)
      ..writeByte(9)
      ..write(obj.lastSignInTime)
      ..writeByte(10)
      ..write(obj.labels);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
