import 'package:hive_flutter/hive_flutter.dart';
import 'package:vocabulaire/models/vocabulary_group.dart';
import 'package:vocabulaire/services/auth_service.dart';

/// Binds local groups (and thereby their boxes) to the signed-in account.
class LocalOwnershipService {
  LocalOwnershipService._();

  static final LocalOwnershipService instance = LocalOwnershipService._();

  Box<VocabularyGroup> get _groups => Hive.box<VocabularyGroup>('groups');

  /// Uid of the signed-in account, empty if nobody is signed in.
  String get currentUid => AuthService.instance.currentUser?.uid ?? '';

  /// Whether [group] is a local group owned by the signed-in account.
  bool isOwnLocalGroup(VocabularyGroup? group) {
    final uid = currentUid;
    return group != null &&
        group.id.isNotEmpty &&
        uid.isNotEmpty &&
        group.ownerUid == uid;
  }

  /// Ids of all local groups owned by [uid] (default: signed-in account).
  Set<String> ownLocalGroupIds({String? uid}) {
    final owner = uid ?? currentUid;
    if (owner.isEmpty) return {};
    return _groups.values
        .where((g) => g.id.isNotEmpty && g.ownerUid == owner)
        .map((g) => g.id)
        .toSet();
  }

  // TODO(2.0): remove legacy ownerUid migration
  /// Assigns local groups created before ownership existed to the signed-in
  /// account.
  Future<void> adoptLegacyGroups() async {
    final uid = currentUid;
    if (uid.isEmpty) return;
    final legacy = _groups.values
        .where((g) => g.id.isNotEmpty && g.ownerUid.isEmpty)
        .toList();
    for (final group in legacy) {
      await _groups.put(group.id, group.copyWith(ownerUid: uid));
    }
  }
}
