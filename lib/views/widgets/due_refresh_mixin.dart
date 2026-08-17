import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../models/vocabulary.dart';

/// Mixin for [State] classes that need to rebuild themselves the moment a
/// [Vocabulary]'s card transitions from "not due" to "due".
mixin DueRefreshMixin<T extends StatefulWidget> on State<T> {
  Timer? _dueRefreshTimer;
  DateTime? _scheduledDueRefresh;

  void scheduleDueRebuild(List<Vocabulary> vocabularies) {
    final now = DateTime.now();
    DateTime? nextDue;
    for (final v in vocabularies) {
      if (v.card.due.isAfter(now)) {
        if (nextDue == null || v.card.due.isBefore(nextDue)) {
          nextDue = v.card.due;
        }
      }
    }

    if (nextDue == _scheduledDueRefresh) return;

    _dueRefreshTimer?.cancel();
    _scheduledDueRefresh = nextDue;
    if (nextDue == null) return;

    final delay = nextDue.difference(now);
    _dueRefreshTimer = Timer(delay.isNegative ? Duration.zero : delay, () {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _dueRefreshTimer?.cancel();
    super.dispose();
  }
}
