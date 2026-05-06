import 'package:hive/hive.dart';
import 'package:vocabulaire/models/app_settings.dart';

class SettingsController {
  static const String settingsBoxName = 'settings';

  final Box<AppSettings> _settingsBox = Hive.box<AppSettings>("settings");

  Future<void> setCardAnimations(bool enabled) async {
    await _settingsBox.put('app_settings', AppSettings(cardAnimations: enabled));
  }

  bool getCardAnimations() {
    final settings = _settingsBox.get('app_settings');
    return settings?.cardAnimations ?? true;
  }
}