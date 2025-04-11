import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// DateTime extension
extension DateTimeExtension on DateTime {
  DateTime toDate() {
    if (isUtc) {
      return DateTime.utc(year, month, day);
    }
    return DateTime(year, month, day);
  }

  String format(String? format) {
    format = format ??
        '${DateFormat.YEAR_MONTH_DAY} ${DateFormat.HOUR24_MINUTE_SECOND}';
    return DateFormat(format).format(this);
  }

  bool inTime(TimeOfDay start, TimeOfDay end) {
    final startTime = copyWith(hour: start.hour, minute: start.minute);
    final endTime = copyWith(hour: end.hour, minute: end.minute);
    return isAfter(startTime) && isBefore(endTime);
  }

  bool get isInPDT => _checkPDT();

  bool get isInCEST => _checkCEST();

  bool _checkPDT() {
    final now = toUtc();
    final start = _getWeekdayInWeekOfMonth(now.year, 3, DateTime.sunday, 2)
        .add(const Duration(hours: 2));
    final end = _getWeekdayInWeekOfMonth(now.year, 11, DateTime.sunday, 1)
        .add(const Duration(hours: 2));
    return now.isAfter(start) && now.isBefore(end);
  }

  bool _checkCEST() {
    final now = toUtc();
    final start = _getLastWeekdayOfMonth(now.year, 3, DateTime.sunday, 1)
        .add(const Duration(hours: 2));
    final end = _getLastWeekdayOfMonth(now.year, 10, DateTime.sunday, 1)
        .add(const Duration(hours: 2));
    return now.isAfter(start) && now.isBefore(end);
  }

  DateTime _getWeekdayInWeekOfMonth(
    int year,
    int month,
    int weekday,
    int weekIndex,
  ) {
    DateTime result = DateTime.utc(year, month, 1);
    while (result.weekday != weekday) {
      result = result.add(const Duration(days: 1));
    }
    return result;
  }

  DateTime _getLastWeekdayOfMonth(
    int year,
    int month,
    int weekday,
    int weekIndex, //week offset from end of month
  ) {
    DateTime result =
        DateTime.utc(year, month + 1, 1).subtract(const Duration(days: 1));
    while (result.weekday != weekday) {
      result = result.subtract(const Duration(days: 1));
    }
    return result;
  }
}
