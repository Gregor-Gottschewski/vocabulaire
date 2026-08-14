import 'package:hive/hive.dart';

part 'pending_audio_upload.g.dart';

/// [PendingAudioUpload] represents a not-yet-uploaded audio recording.
@HiveType(typeId: 3, adapterName: 'PendingAudioUploadAdapter')
class PendingAudioUpload {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String boxId;

  @HiveField(2)
  final int attempts;

  @HiveField(3)
  final DateTime createdAt;

  PendingAudioUpload({
    required this.id,
    required this.boxId,
    this.attempts = 0,
    required this.createdAt,
  });

  PendingAudioUpload copyWith({int? attempts}) {
    return PendingAudioUpload(
      id: id,
      boxId: boxId,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt,
    );
  }
}
