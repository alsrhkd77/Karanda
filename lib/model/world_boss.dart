import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/utils/time_of_day_parser.dart';

class WorldBoss {
  final String name;
  int weekday;
  TimeOfDay spawnTime;
  final BDORegion region;
  final DateTime? start;
  final DateTime? end;

  late final String imagePath;

  bool get isEventBoss => start != null && end != null;

  WorldBoss({
    required this.name,
    required this.weekday,
    required this.spawnTime,
    required this.region,
    this.start,
    this.end,
  }) {
    if (start != null && end != null) {
      imagePath = "${Api.worldBossPortrait}/event.png";
    } else {
      imagePath = "${Api.worldBossPortrait}/${name.replaceAll(" ", "_")}.png";
    }
  }

  factory WorldBoss.fromJson(Map json) {
    return WorldBoss(
      name: json["name"],
      weekday: json["utc weekday"],
      spawnTime: TimeOfDayParser.parse(json["utc spawn time"]),
      region: BDORegion.values.byName(json["region"]),
      start: DateTime.tryParse(json["start"]),
      end: DateTime.tryParse(json["end"]),
    );
  }

  Map toJson() {
    Map data = {
      "name": name,
      "utc weekday": weekday,
      "utc spawn time": "${spawnTime.hour}:${spawnTime.minute}",
      "region": region.name,
      "start": start?.toString() ?? "",
      "end": end?.toString() ?? "",
    };
    return data;
  }
}
