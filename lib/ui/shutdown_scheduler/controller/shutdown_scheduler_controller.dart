import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:karanda/repository/time_repository.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 예약 종료 기능 운영 로그.
final _log = Logger('shutdown_scheduler');

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
    _log.info('Shutdown scheduler initialized (existing reservation: '
        '${scheduled == true ? target.toIso8601String() : "none"})');
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
    _log.info('Shutdown scheduled at ${target.toIso8601String()}');
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
