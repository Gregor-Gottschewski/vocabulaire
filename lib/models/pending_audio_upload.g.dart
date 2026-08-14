// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_audio_upload.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingAudioUploadAdapter extends TypeAdapter<PendingAudioUpload> {
  @override
  final int typeId = 3;

  @override
  PendingAudioUpload read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingAudioUpload(
      id: fields[0] as String,
      boxId: fields[1] as String,
      attempts: fields[2] as int,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PendingAudioUpload obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.boxId)
      ..writeByte(2)
      ..write(obj.attempts)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingAudioUploadAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
