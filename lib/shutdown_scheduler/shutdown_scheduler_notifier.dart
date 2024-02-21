import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShutdownSchedulerNotifier with ChangeNotifier {
  final String _key = 'shutdown-schedule';
  bool running = false;
  DateTime target = DateTime.now();

  ShutdownSchedulerNotifier() {
    checkSchedule();
  }

  Future<void> checkSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_key)) {
      DateTime schedule = DateTime.parse(prefs.getString(_key)!);
      if (schedule.isAfter(DateTime.now())) {
        running = true;
        target = schedule;
        notifyListeners();
      } else {
        prefs.remove(_key);
      }
    }
  }

  Future<void> startSchedule(TimeOfDay selected) async {
    final prefs = await SharedPreferences.getInstance();
    target =
        DateTime.now().copyWith(hour: selected.hour, minute: selected.minute);
    if (target.difference(DateTime.now()).inMinutes < 1) {
      target = target.add(const Duration(days: 1));
    }
    prefs.setString(_key, target.toString());
    int sec = target.difference(DateTime.now()).inSeconds;
    Process.start('shutdown', ['-s', '-f', '-t', '$sec']);
    running = true;
    notifyListeners();
  }

  Future<void> cancelSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    bool result = await prefs.remove(_key);
    if (result) {
      Process.start('shutdown', ['-a']);
      running = false;
      notifyListeners();
    }
  }

  void forceCancel() {
    Process.start('shutdown', ['-a']);
    running = false;
    notifyListeners();
  }
}
