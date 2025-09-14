import 'package:flutter/material.dart';

/*
 * TimeOfDay's custom extension
 */
extension TimeOfDayExtension on TimeOfDay {
  int compareTo(TimeOfDay other) {
    if (hour < other.hour) return -1;
    if (hour > other.hour) return 1;
    if (minute < other.minute) return -1;
    if (minute > other.minute) return 1;
    return 0;
  }

  TimeOfDay add(Duration duration) {
    final base = DateTime(1996, 11, 12, hour, minute);
    final result = base.add(duration);
    return TimeOfDay(hour: result.hour, minute: result.minute);
  }

  TimeOfDay subtract(Duration duration) => add(-duration);

  bool isBetween(TimeOfDay start, TimeOfDay end) {
    final currentMinutes = (hour * 60) + minute;
    final startMinutes = (start.hour * 60) + start.minute;
    final endMinutes = (end.hour * 60) + end.minute;

    if (startMinutes <= endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // 자정을 넘어갈 경우
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }
}
