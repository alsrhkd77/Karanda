import 'package:flutter/material.dart';
import 'package:karanda/world_boss_timer/models/spawn_time.dart';

class Boss {
  late String name;
  late List<SpawnTime> spawnTimesKR;

  Boss.fromData(Map data) {
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

  }
}
