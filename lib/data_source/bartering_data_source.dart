import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:karanda/model/bartering/bartering_mastery.dart';
import 'package:karanda/model/bartering/bartering_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BarteringDataSource {
  final String _key = "bartering";

  Future<List<BarteringMastery>> loadMasteryData() async {
    final List<BarteringMastery> result = [];
    final data =
        jsonDecode(await rootBundle.loadString("assets/data/bartering.json"));
    for (Map json in data["mastery"]) {
      result.add(BarteringMastery.fromJson(json));
    }
    return result;
  }

  Future<BarteringSettings> loadSettings() async {
    final pref = SharedPreferencesAsync();
    final data = await pref.getString("${_key}_settings");
    if(data != null){
      return BarteringSettings.fromJson(jsonDecode(data));
    }
    return BarteringSettings();
  }

  Future<void> saveSettings(BarteringSettings value) async {
    final pref = SharedPreferencesAsync();
    await pref.setString("${_key}_settings", jsonEncode(value.toJson()));
  }
}
