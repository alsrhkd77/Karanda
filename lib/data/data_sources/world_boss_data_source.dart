import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:karanda/data/model/world_boss.dart';

class WorldBossDataSource {
  Future<List<WorldBoss>> getWorldBossTimetable() async {
    final List data = jsonDecode(
        await rootBundle.loadString('assets/data/world_boss_timetable.json'));
    final List<WorldBoss> result = [];
    for (Map d in data) {
      result.add(WorldBoss.fromJson(d));
    }
    return result;
  }
}
