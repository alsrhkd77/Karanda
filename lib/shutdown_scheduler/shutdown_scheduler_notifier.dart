import 'dart:async';

import 'package:flutter/material.dart';

class ShutdownSchedulerNotifier with ChangeNotifier {
  bool running = false;
  TimeOfDay target = TimeOfDay.now();
  TimeOfDay now = TimeOfDay.now();
  Timer? _timer;

  void startSchedule(TimeOfDay selected) {
    if (running) return;
    target = selected;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => checkTime());
    running = true;
    notifyListeners();
  }

  void cancelSchedule() {
    running = false;
    _timer?.cancel();
    notifyListeners();
  }

  String getTimeInterval() {
    int hour = target.hour - now.hour;
    int minute = target.minute - now.minute;
    if (minute < 0) {
      minute += 60;
    }
    if(hour == 0){
      return '$minute분';
    }
    else if (hour < 0) {
      hour += 24;
    }
    return '$hour시간 $minute분';
  }

  void checkTime() {
    now = TimeOfDay.now();
    notifyListeners();
    if (target == now) {
      shutdown();
    }
  }

  void shutdown() {
    running = false;
    _timer?.cancel();
    print('shutdown');
    notifyListeners();
  }

  @override
  dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
