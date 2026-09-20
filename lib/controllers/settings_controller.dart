import 'package:hive/hive.dart';
import 'package:vocabulaire/models/app_settings.dart';

class SettingsController {
  static const String settingsBoxName = 'settings';
  static const String _hiveKey = 'app_settings';

  final Box<AppSettings> _settingsBox = Hive.box<AppSettings>(settingsBoxName);

  Future<void> setCardAnimations(bool enabled) async {
    await _settingsBox.put(
      _hiveKey,
      AppSettings(cardAnimations: enabled, updatedAt: DateTime.now()),
    );
  }

  bool getCardAnimations() {
    final settings = _settingsBox.get(_hiveKey);
    return settings?.cardAnimations ?? true;
  }

  /// The stored settings, or null if the user never changed any.
  AppSettings? get settings => _settingsBox.get(_hiveKey);

  /// Emits whenever the stored settings change.
  Stream<AppSettings?> watch() =>
      _settingsBox.watch(key: _hiveKey).map((event) => event.value as AppSettings?);

  /// Stores settings received from another device, keeping their `updatedAt`.
  Future<void> applyRemote(AppSettings remote) async {
    await _settingsBox.put(_hiveKey, remote);
  }
}
