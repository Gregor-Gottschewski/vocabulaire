import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:vocabulaire/models/hive_types.dart';

part 'app_settings.g.dart';

@HiveType(typeId: HiveTypes.appSettingsTypeId, adapterName: 'AppSettingsAdapter')
class AppSettings {
  @HiveField(0, defaultValue: true)
  final bool cardAnimations;

  /// Time of the last change. Used to resolve conflicts when syncing.
  @HiveField(1)
  final DateTime? updatedAt;

  AppSettings({required this.cardAnimations, this.updatedAt});

  /// Fields synced to Firestore. `ownerUid` and `updatedAt` are added by the
  /// sync service.
  Map<String, dynamic> toFirestore() => {'cardAnimations': cardAnimations};

  factory AppSettings.fromFirestore(Map<String, dynamic> data) => AppSettings(
    cardAnimations: data['cardAnimations'] as bool? ?? true,
    updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
  );
}
