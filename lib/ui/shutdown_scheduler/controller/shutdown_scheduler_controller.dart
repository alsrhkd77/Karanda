import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:karanda/repository/time_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShutdownSchedulerController extends ChangeNotifier {
  final TimeRepository _timeRepository;
  final String _key = "shutdown-schedule";
  late StreamSubscription _realTime;

  bool? scheduled;
  DateTime now = DateTime.now();
  DateTime? _target;

  ShutdownSchedulerController({required TimeRepository timeRepository})
      : _timeRepository = timeRepository {
    checkSchedule();
    _realTime = _timeRepository.realTimeStream.listen(_onTimeUpdate);
  }

  DateTime get target => _target ?? now;

  Future<void> checkSchedule() async {
    final pref = SharedPreferencesAsync();
    final data = await pref.getString(_key);
    scheduled = false;
    if (data != null) {
      DateTime schedule = DateTime.tryParse(data) ?? DateTime(1996);
      if (schedule.isAfter(now)) {
        scheduled = true;
        _target = schedule;
      } else {
        pref.remove(_key);
      }
    }
    notifyListeners();
  }

  void setTarget(TimeOfDay value){
    _target = now.copyWith(hour: value.hour, minute: value.minute, second: 0);
    if(target.difference(now).inMinutes < 1){
      _target = target.add(Duration(days: 1));
    }
    notifyListeners();
  }

  void setSchedule() {
    final pref = SharedPreferencesAsync();
    if(target.difference(now).inMinutes < 1){
      _target = target.add(Duration(days: 1));
    }
    int sec = target.difference(now).inSeconds;
    Process.start('shutdown', ['-s', '-f', '-t', '$sec']);
    pref.setString(_key, target.toString());
    scheduled = true;
    notifyListeners();
  }

  void cancelSchedule(){
    final pref = SharedPreferencesAsync();
    pref.remove(_key);
    Process.start('shutdown', ['-a']);
    scheduled = false;
    notifyListeners();
  }

  void _onTimeUpdate(DateTime value) {
    now = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _realTime.cancel();
    super.dispose();
  }
}
