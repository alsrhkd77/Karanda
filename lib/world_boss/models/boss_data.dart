import 'package:flutter/material.dart';
import 'package:karanda/common/time_of_day_extension.dart';
import 'package:karanda/world_boss/models/spawn_time.dart';

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

  bool check(DateTime time){
    TimeOfDay timeOfDay = TimeOfDay.fromDateTime(time);
    for(SpawnTime spawnTime in spawnTimesKR){
      if(spawnTime.timeOfDay == timeOfDay){
        if(spawnTime.weekday == 0 || spawnTime.weekday == time.weekday){
          return true;
        }
      }
    }
    return false;
  }
}
