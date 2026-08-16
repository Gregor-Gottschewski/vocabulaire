import 'package:vocabulaire/firebase_options.dart' as stable_options;
import 'package:vocabulaire/firebase_options_dev.dart' as dev_options;
import 'package:firebase_core/firebase_core.dart';

enum Flavor { dev, stable }

class FlavorConfig {
  final Flavor flavor;
  final String appName;
  final FirebaseOptions firebaseOptions;

  FlavorConfig._({required this.flavor, required this.appName, required this.firebaseOptions});

  static FlavorConfig? _instance;

  static FlavorConfig get instance {
    assert(_instance != null, 'FlavorConfig.init() must be called before FlavorConfig.instance is accessed');
    return _instance!;
  }

  static void init(Flavor flavor) {
    _instance = switch (flavor) {
      Flavor.dev => FlavorConfig._(
        flavor: Flavor.dev,
        appName: 'Vocabulaire Dev',
        firebaseOptions: dev_options.DefaultFirebaseOptionsDev.currentPlatform,
      ),
      Flavor.stable => FlavorConfig._(
        flavor: Flavor.stable,
        appName: 'Vocabulaire',
        firebaseOptions: stable_options.DefaultFirebaseOptions.currentPlatform,
      ),
    };
  }
}
