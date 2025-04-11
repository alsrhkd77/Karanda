import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/world_boss.dart';
import 'package:karanda/model/world_boss_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorldBossDataSource {
  final String _jsonPath = "assets/data/world_boss_timetable.json";
  final String _settingsKey = "world-boss-settings";

  Future<List<WorldBoss>> getFixedWorldBoss(BDORegion region) async {
    final List<WorldBoss> result = [];
    final json = await rootBundle.loadString(_jsonPath);
    for(Map item in jsonDecode(json)){
      final data = WorldBoss.fromJson(item);
      if(data.region == region){
        result.add(data);
      }
    }
    return result;
  }
  void getEventWorldBoss(BDORegion region){}

  Future<WorldBossSettings> loadSettings() async {
    final pref = SharedPreferencesAsync();
    final data = await pref.getString(_settingsKey);
    if(data != null){
      return WorldBossSettings.fromJson(jsonDecode(data));
    }
    return WorldBossSettings();
  }

  Future<void> saveSettings(WorldBossSettings settings) async {
    final pref = SharedPreferencesAsync();
    await pref.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
}
