// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VocabularyGroupAdapter extends TypeAdapter<VocabularyGroup> {
  @override
  final int typeId = 5;

  @override
  VocabularyGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VocabularyGroup(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      sourceLanguage: fields[3] as String?,
      targetLanguage: fields[4] as String?,
      deleted: fields[5] == null ? false : fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, VocabularyGroup obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.sourceLanguage)
      ..writeByte(4)
      ..write(obj.targetLanguage)
      ..writeByte(5)
      ..write(obj.deleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabularyGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
