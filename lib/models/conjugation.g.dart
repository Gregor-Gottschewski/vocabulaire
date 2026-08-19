// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conjugation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConjugationAdapter extends TypeAdapter<Conjugation> {
  @override
  final int typeId = 4;

  @override
  Conjugation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Conjugation(
      temps: fields[0] as String,
      forms: fields[1] as String,
      cardData: (fields[2] as Map).cast<String, dynamic>(),
      id: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Conjugation obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.temps)
      ..writeByte(1)
      ..write(obj.forms)
      ..writeByte(2)
      ..write(obj.cardData)
      ..writeByte(3)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConjugationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
