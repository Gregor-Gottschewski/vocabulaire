import 'package:hive/hive.dart';
import 'package:vocabulaire/models/app_settings.dart';

class SettingsController {
  static const String settingsBoxName = 'settings';
  static const String _hiveKey = 'app_settings';

  final Box<AppSettings> _settingsBox = Hive.box<AppSettings>(settingsBoxName);

  Future<void> setCardAnimations(bool enabled) async {
    await _update((s) => s.copyWith(cardAnimations: enabled));
  }

  Future<void> setListeningInReview(ListeningMode mode) async {
    await _update((s) => s.copyWith(listeningInReview: mode));
  }

  ListeningMode getListeningInReview() =>
      _settingsBox.get(_hiveKey)?.listeningInReview ?? ListeningMode.sometimes;

  Future<void> _update(AppSettings Function(AppSettings) change) async {
    final current =
        _settingsBox.get(_hiveKey) ?? AppSettings(cardAnimations: true);
    await _settingsBox.put(
      _hiveKey,
      change(current).copyWith(updatedAt: DateTime.now()),
    );
  }

  bool getCardAnimations() {
    final settings = _settingsBox.get(_hiveKey);
    return settings?.cardAnimations ?? true;
  }

  /// The stored settings, or null if the user never changed any.
  AppSettings? get settings => _settingsBox.get(_hiveKey);

  /// Emits whenever the stored settings change.
  Stream<AppSettings?> watch() => _settingsBox
      .watch(key: _hiveKey)
      .map((event) => event.value as AppSettings?);

  /// Stores settings received from another device, keeping their `updatedAt`.
  Future<void> applyRemote(AppSettings remote) async {
    await _settingsBox.put(_hiveKey, remote);
  }
}
