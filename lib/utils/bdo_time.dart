import 'package:flutter/material.dart';
import 'package:karanda/utils/extension/date_time_extension.dart';
import 'package:karanda/utils/extension/time_of_day_extension.dart';

class BdoTime {
  // 밤 타임 시작 시각 (UTC 기준)
  final List<TimeOfDay> _cycle = [
    TimeOfDay(hour: 3, minute: 40),
    TimeOfDay(hour: 7, minute: 40),
    TimeOfDay(hour: 11, minute: 40),
    TimeOfDay(hour: 15, minute: 40),
    TimeOfDay(hour: 19, minute: 40),
    TimeOfDay(hour: 23, minute: 40),
  ];

  late final TimeOfDay bdoTime;
  late final bool isNight;
  late final DateTime lastTransition;
  late final DateTime nextTransition;
  late final double progress;

  BdoTime(DateTime dateTime) {
    final utc = dateTime.toUtc();
    final now = TimeOfDay.fromDateTime(utc);
    bool night = false;
    late DateTime next, last;
    for (TimeOfDay start in _cycle) {
      final end = start.add(const Duration(minutes: 40));
      if (now.isBetween(start, end)) {
        night = true;
        last = utc.toDate().copyWith(hour: start.hour, minute: start.minute);
        next = utc.toDate().copyWith(hour: end.hour, minute: end.minute);
        break;
      }
    }
    if (!night) {
      final end = _cycle.firstWhere(
        (cycle) => cycle.isAfter(now),
        orElse: () => _cycle.first,
      );
      final start = end.subtract(const Duration(minutes: 200));
      last = utc.toDate().copyWith(hour: start.hour, minute: start.minute);
      next = utc.toDate().copyWith(hour: end.hour, minute: end.minute);
    }
    isNight = night;
    lastTransition =
        last.isAfter(utc) ? last.subtract(const Duration(days: 1)) : last;
    nextTransition =
        next.isBefore(utc) ? next.add(const Duration(days: 1)) : next;
    progress = utc.difference(lastTransition).inSeconds /
        nextTransition.difference(lastTransition).inSeconds;

    /* 인게임 시간 계산 */
    final base = isNight
        ? TimeOfDay(hour: 22, minute: 0)
        : TimeOfDay(hour: 7, minute: 0);
    final sec =
        utc.difference(lastTransition).inSeconds * (isNight ? 13.5 : 4.5);
    bdoTime = base.add(Duration(seconds: sec.floor()));
  }
}
