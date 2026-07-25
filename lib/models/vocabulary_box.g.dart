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
      dailyLimitEnabled: fields[8] == null ? false : fields[8] as bool,
      dailyLimit: fields[9] == null ? 20 : fields[9] as int,
      newCardsReviewedToday: fields[10] == null ? 0 : fields[10] as int,
      lastNewVocabularyReview: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, VocabularyBox obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.targetLanguage)
      ..writeByte(8)
      ..write(obj.dailyLimitEnabled)
      ..writeByte(9)
      ..write(obj.dailyLimit)
      ..writeByte(10)
      ..write(obj.newCardsReviewedToday)
      ..writeByte(11)
      ..write(obj.lastNewVocabularyReview);
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
