import 'package:flutter/material.dart';
import 'package:karanda/common/api.dart';

class WorldBossData {
  final String name;
  final WorldBossType type;
  final TimeOfDay spawnTime;
  final String region;
  DateTime? start;
  DateTime? end;

  late final String imagePath;

  WorldBossData({
    required this.name,
    required this.type,
    required this.spawnTime,
    required this.region,
    this.start,
    this.end,
  }) {
    if (type == WorldBossType.fixed) {
      imagePath = "${Api.worldBossPortrait}/${name.replaceAll(" ", "_")}.png";
    } else {
      imagePath = "${Api.worldBossPortrait}/event.png";
    }
  }

  factory WorldBossData.fromJson(Map data) {
    final parsed = (data["spawn time"] as String).split(":");
    final spawnTime = TimeOfDay(
      hour: int.parse(parsed.first),
      minute: int.parse(parsed.last),
    );
    if (data.containsKey("start") && data.containsKey("end")) {
      return WorldBossData(
        name: data["name"],
        type: WorldBossType.event,
        spawnTime: spawnTime,
        region: data["region"],
        start: DateTime.parse(data["start"]),
        end: DateTime.parse(data["end"]),
      );
    }
    return WorldBossData(
      name: data["name"],
      type: WorldBossType.fixed,
      spawnTime: spawnTime,
      region: data["region"],
    );
  }
}

enum WorldBossType { fixed, event }
