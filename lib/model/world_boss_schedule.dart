import 'package:karanda/model/world_boss.dart';

class WorldBossSchedule {
  DateTime spawnTime;
  List<WorldBoss> bosses = [];

  WorldBossSchedule({required this.spawnTime, List<WorldBoss>? bosses}) {
    this.bosses = bosses ?? this.bosses;
  }

  ///고정 보스 & [spawnTime]이 이벤트 기간내 이벤트 보스
  List<WorldBoss> get activatedBosses => bosses.where((data) {
        if (data.isEventBoss) {
          if (data.start!.isAfter(spawnTime) || data.end!.isBefore(spawnTime)) {
            return false;
          }
        }
        return true;
      }).toList();

  factory WorldBossSchedule.fromJson(Map json) {
    final List<WorldBoss> bossData = [];
    for (Map item in json["bosses"]) {
      bossData.add(WorldBoss.fromJson(item));
    }
    return WorldBossSchedule(
      spawnTime: DateTime.parse(json["spawnTime"]),
      bosses: bossData,
    );
  }

  Map toJson() {
    return {
      "spawnTime": spawnTime.toString(),
      "bosses": bosses.map((boss) => boss.toJson()).toList(),
    };
  }

  WorldBossSchedule toPreviousSchedule() {
    return WorldBossSchedule(
      spawnTime: spawnTime.subtract(const Duration(days: 7)),
      bosses: bosses,
    );
  }
}
