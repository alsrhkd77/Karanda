import 'package:flutter/material.dart';
import 'package:karanda/common/time_of_day_extension.dart';
import 'package:karanda/world_boss_timer/models/spawn_time.dart';

class BossData {
  late String name;
  late List<SpawnTime> spawnTimesKR;

  BossData.fromData(Map data) {
    name = data["name"];
    spawnTimesKR = [];

    for (Map k in data["kr"]) {
      spawnTimesKR.add(SpawnTime(
        k["weekday"],
        TimeOfDay(
          hour: k["hour"],
          minute: k["minute"],
        ),
      ));
    }
    spawnTimesKR.sort((a, b) => a.timeOfDay.compareTo(b.timeOfDay));
  }
}
