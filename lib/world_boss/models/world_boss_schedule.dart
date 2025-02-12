import 'package:flutter/material.dart';

class WorldBossSchedule {
  final int weekday;
  final TimeOfDay schedule;
  Set<String> bosses = {};

  WorldBossSchedule({required this.weekday, required this.schedule});

  factory WorldBossSchedule.fromJson(Map data) {
    return WorldBossSchedule(
      weekday: data["weekday"],
      schedule: TimeOfDay(hour: data["hour"], minute: data["minute"]),
    );
  }

  List<WorldBossSchedule> toList() {
    if (weekday == 0) {
      return List.generate(
        7,
        (index) => WorldBossSchedule(weekday: index + 1, schedule: schedule),
      );
    }
    return [this];
  }

  @override
  int get hashCode => Object.hash(weekday, schedule);

  @override
  bool operator ==(Object other) {
    if (other is WorldBossSchedule) {
      return weekday == other.weekday && schedule == other.schedule;
    }
    return false;
  }
}
