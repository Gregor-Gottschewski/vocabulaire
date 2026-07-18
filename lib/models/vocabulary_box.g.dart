// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_box.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VocabularyBoxAdapter extends TypeAdapter<VocabularyBox> {
  @override
  final int typeId = 1;

  @override
  VocabularyBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VocabularyBox(
      name: fields[0] as String,
      description: fields[1] as String,
      vocabularies: (fields[2] as List).cast<Vocabulary>(),
      type: fields[3] as String,
      icon: fields[4] as String,
      color: fields[5] as String,
      sourceLanguage: fields[6] as String?,
      targetLanguage: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VocabularyBox obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.vocabularies)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.icon)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.sourceLanguage)
      ..writeByte(7)
      ..write(obj.targetLanguage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabularyBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
