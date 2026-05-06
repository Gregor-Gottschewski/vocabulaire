import 'package:hive/hive.dart';
import 'package:vocabulaire/models/hive_types.dart';

part 'app_settings.g.dart';

@HiveType(typeId: HiveTypes.appSettingsTypeId, adapterName: 'AppSettingsAdapter')
class AppSettings {
  @HiveField(0, defaultValue: true)
  final bool cardAnimations;

  AppSettings({required this.cardAnimations});
}