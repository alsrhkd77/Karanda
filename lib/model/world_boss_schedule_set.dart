import 'package:karanda/model/world_boss_schedule.dart';

class WorldBossScheduleSet {
  final WorldBossSchedule previous;
  final WorldBossSchedule current;
  final WorldBossSchedule next;

  WorldBossScheduleSet({
    required this.previous,
    required this.current,
    required this.next,
  });

  factory WorldBossScheduleSet.fromJson(Map json) {
    return WorldBossScheduleSet(
      previous: WorldBossSchedule.fromJson(json["previous"]),
      current: WorldBossSchedule.fromJson(json["current"]),
      next: WorldBossSchedule.fromJson(json["next"]),
    );
  }

  Map toJson() {
    return {
      "previous": previous.toJson(),
      "current": current.toJson(),
      "next": next.toJson()
    };
  }
}
