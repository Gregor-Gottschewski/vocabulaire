import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:vocabulaire/models/hive_types.dart';

part 'app_settings.g.dart';

enum ListeningMode {
  always,
  sometimes,
  never;

  /// Returns [ListeningMode] based on its name
  static ListeningMode fromName(String? name) => ListeningMode.values
      .firstWhere((m) => m.name == name, orElse: () => ListeningMode.sometimes);

  /// Decides whether a card is presented as audio only.
  bool shouldListen({required bool hasAudio, Random? random}) {
    if (!hasAudio) return false;
    return switch (this) {
      ListeningMode.always => true,
      ListeningMode.sometimes => (random ?? Random()).nextBool(),
      ListeningMode.never => false,
    };
  }
}

@HiveType(
  typeId: HiveTypes.appSettingsTypeId,
  adapterName: 'AppSettingsAdapter',
)
class AppSettings {
  @HiveField(0, defaultValue: true)
  final bool cardAnimations;

  /// Time of the last change. Used to resolve conflicts when syncing.
  @HiveField(1)
  final DateTime? updatedAt;

  /// [ListeningMode.name] of the listening-in-review setting.
  @HiveField(2, defaultValue: 'sometimes')
  final String listeningInReviewName;

  ListeningMode get listeningInReview =>
      ListeningMode.fromName(listeningInReviewName);

  AppSettings({
    required this.cardAnimations,
    this.listeningInReviewName = 'sometimes',
    this.updatedAt,
  });

  AppSettings copyWith({
    bool? cardAnimations,
    ListeningMode? listeningInReview,
    DateTime? updatedAt,
  }) => AppSettings(
    cardAnimations: cardAnimations ?? this.cardAnimations,
    listeningInReviewName: (listeningInReview ?? this.listeningInReview).name,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  /// Fields synced to Firestore. `ownerUid` and `updatedAt` are added by the
  /// sync service.
  Map<String, dynamic> toFirestore() => {
    'cardAnimations': cardAnimations,
    'listeningInReview': listeningInReview.name,
  };

  factory AppSettings.fromFirestore(Map<String, dynamic> data) => AppSettings(
    cardAnimations: data['cardAnimations'] as bool? ?? true,
    listeningInReviewName: ListeningMode.fromName(
      data['listeningInReview'] as String?,
    ).name,
    updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
  );
}
