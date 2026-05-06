import 'package:flutter/foundation.dart';

class CounterController {
  final ValueNotifier<int> counter = ValueNotifier<int>(0);

  void incrementCounter() {
    counter.value++;
  }
}
