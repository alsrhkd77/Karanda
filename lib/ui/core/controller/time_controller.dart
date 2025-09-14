import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/repository/time_repository.dart';

class TimeController extends ChangeNotifier {
  late final StreamSubscription _time;

  TimeController({required TimeRepository timeRepository}) {
    _time = timeRepository.realTimeStream.listen(_onUpdate);
  }

  DateTime local = DateTime.now();
  DateTime utc = DateTime.now().toUtc();

  void _onUpdate(DateTime value) {
    local = value;
    utc = local.toUtc();
    notifyListeners();
  }

  @override
  void dispose() {
    _time.cancel();
    super.dispose();
  }
}
