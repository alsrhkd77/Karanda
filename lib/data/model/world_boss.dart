import 'package:flutter/material.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/utils/TimeOfDayParser.dart';

class WorldBoss {
  final String name;
  final TimeOfDay spawnTime;
  final String region;
  DateTime? start;
  DateTime? end;

  late final String imagePath;

  WorldBoss({
    required this.name,
    required this.spawnTime,
    required this.region,
    this.start,
    this.end,
  }) {
    if (start != null && end != null) {
      imagePath = "${Api.worldBossPortrait}/${name.replaceAll(" ", "_")}.png";
    } else {
      imagePath = "${Api.worldBossPortrait}/event.png";
    }
  }

  factory WorldBoss.fromJson(Map data) {
    if (data.containsKey("start") && data.containsKey("end")) {
      return WorldBoss(
        name: data["name"],
        spawnTime: TimeOfDayParser.parse(data["spawn time"]),
        region: data["region"],
        start: DateTime.parse(data["start"]),
        end: DateTime.parse(data["end"]),
      );
    }
    return WorldBoss(
      name: data["name"],
      spawnTime: TimeOfDayParser.parse(data["spawn time"]),
      region: data["region"],
    );
  }
}
