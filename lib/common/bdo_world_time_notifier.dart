import 'dart:async';

import 'package:flutter/material.dart';

/*
* 밤타임: 22:00 ~ 07:00
* 낮타임: 현실 1분 = 인게임 4.5분
* 밤타임: 현실 1분 = 인게임 13.5분
*/
class BdoWorldTimeNotifier with ChangeNotifier {
  final List<Map> timeChart = [
    {
      'ref': const TimeOfDay(hour: 19, minute: 00),
      'sec': 270,
      'start': const TimeOfDay(hour: 00, minute: 00),
      'end': const TimeOfDay(hour: 00, minute: 39)
    },
    {
      'ref': const TimeOfDay(hour: 22, minute: 00),
      'sec': 810,
      'start': const TimeOfDay(hour: 00, minute: 40),
      'end': const TimeOfDay(hour: 1, minute: 19)
    },
    {
      'ref': const TimeOfDay(hour: 7, minute: 00),
      'sec': 270,
      'start': const TimeOfDay(hour: 1, minute: 20),
      'end': const TimeOfDay(hour: 4, minute: 39)
    },
    {
      'ref': const TimeOfDay(hour: 22, minute: 00),
      'sec': 810,
      'start': const TimeOfDay(hour: 4, minute: 40),
      'end': const TimeOfDay(hour: 5, minute: 19)
    },
    {
      'ref': const TimeOfDay(hour: 7, minute: 00),
      'sec': 270,
      'start': const TimeOfDay(hour: 5, minute: 20),
      'end': const TimeOfDay(hour: 8, minute: 39)
    },
    {
      'ref': const TimeOfDay(hour: 22, minute: 00),
      'sec': 810,
      'start': const TimeOfDay(hour: 8, minute: 40),
      'end': const TimeOfDay(hour: 9, minute: 19)
    },
    {
      'ref': const TimeOfDay(hour: 7, minute: 00),
      'sec': 270,
      'start': const TimeOfDay(hour: 9, minute: 20),
      'end': const TimeOfDay(hour: 12, minute: 39)
    },
    {
      'ref': const TimeOfDay(hour: 22, minute: 00),
      'sec': 810,
      'start': const TimeOfDay(hour: 12, minute: 40),
      'end': const TimeOfDay(hour: 13, minute: 19)
    },
    {
      'ref': const TimeOfDay(hour: 7, minute: 00),
      'sec': 270,
      'start': const TimeOfDay(hour: 13, minute: 20),
      'end': const TimeOfDay(hour: 16, minute: 39)
    },
    {
      'ref': const TimeOfDay(hour: 22, minute: 00),
      'sec': 810,
      'start': const TimeOfDay(hour: 16, minute: 40),
      'end': const TimeOfDay(hour: 17, minute: 19)
    },
    {
      'ref': const TimeOfDay(hour: 7, minute: 00),
      'sec': 270,
      'start': const TimeOfDay(hour: 17, minute: 20),
      'end': const TimeOfDay(hour: 20, minute: 39)
    },
    {
      'ref': const TimeOfDay(hour: 22, minute: 00),
      'sec': 810,
      'start': const TimeOfDay(hour: 20, minute: 40),
      'end': const TimeOfDay(hour: 21, minute: 19)
    },
    {
      'ref': const TimeOfDay(hour: 7, minute: 00),
      'sec': 270,
      'start': const TimeOfDay(hour: 21, minute: 20),
      'end': const TimeOfDay(hour: 23, minute: 59)
    }
  ];
  DateTime realTime = DateTime.now();
  TimeOfDay bdoTime = TimeOfDay.now();
  late Timer _timer;

  BdoWorldTimeNotifier() {
    updateBdoTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      realTime = DateTime.now();
      updateBdoTime();
    });
  }

  void updateBdoTime() {
    DateTime result = DateTime.now();
    for (Map target in timeChart) {
      TimeOfDay _start = target['start'];
      TimeOfDay _end = target['end'];
      if (realTime.inTime(_start, _end)) {
        int _sec = ((realTime.hour - _start.hour) * 60 * 60) +
            ((realTime.minute - _start.minute) * 60) +
            realTime.second;
        result = DateTime.now()
            .copyWith(hour: target['ref'].hour, minute: target['ref'].minute);
        _sec = (_sec * (target['sec'] / 60)).round();
        result = result.add(Duration(seconds: _sec));
        break;
      }
    }
    bdoTime = TimeOfDay.fromDateTime(result);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

extension DateTimeExtension on DateTime {
  bool inTime(TimeOfDay start, TimeOfDay end) {
    if(hour == start.hour && minute >= start.minute){
      if(hour == end.hour && minute > end.minute){
        return false;
      }
      return true;
    }
    if (hour > start.hour && hour < end.hour) {
      return true;
    }
    if(hour == end.hour && minute <= end.minute){
      return true;
    }
    return false;
  }
}

