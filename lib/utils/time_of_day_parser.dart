import 'package:flutter/material.dart';

class TimeOfDayParser extends TimeOfDay {
  const TimeOfDayParser({required super.hour, required super.minute});

  factory TimeOfDayParser.parse(String formattedString) {
    final parsed = formattedString.split(":");
    return TimeOfDayParser(
      hour: int.parse(parsed.first),
      minute: int.parse(parsed.last),
    );
  }
}