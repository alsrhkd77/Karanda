import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_data.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShipUpgradingDataSource {
  final String key = "ship-upgrading";

  Future<List<ShipUpgradingData>> loadBaseData() async {
    final List<ShipUpgradingData> result = [];
    final json = jsonDecode(
        await rootBundle.loadString("assets/data/ship_upgrading.json"));
    for (Map data in json) {
      result.add(ShipUpgradingData.fromJson(data));
    }
    return result;
  }

  Future<ShipUpgradingSettings> loadSettings() async {
    final pref = SharedPreferencesAsync();
    final json = await pref.getString("${key}_settings");
    if (json == null) {
      return ShipUpgradingSettings();
    } else {
      return ShipUpgradingSettings.fromJson(jsonDecode(json));
    }
  }

  Future<void> saveSettings(ShipUpgradingSettings value) async {
    final pref = SharedPreferencesAsync();
    await pref.setString("${key}_settings", jsonEncode(value.toJson()));
  }

  Future<int> loadUserStock(int code) async {
    final pref = SharedPreferencesAsync();
    return await pref.getInt("${key}_${code}_stock") ?? 0;
  }

  Future<void> saveUserStock(int code, int value) async {
    final pref = SharedPreferencesAsync();
    await pref.setInt("${key}_${code}_stock", value);
  }
}
