import 'dart:convert';

import 'package:karanda/model/overlay_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverlaySettingsDataSource {
  final String _settingsKey = "overlay-settings";

  Future<OverlaySettings> loadSettings() async {
    final pref = SharedPreferencesAsync();
    final data = await pref.getString(_settingsKey);
    if(data != null){
      return OverlaySettings.fromJson(jsonDecode(data));
    }
    return OverlaySettings();
  }

  Future<void> saveSettings(OverlaySettings value) async {
    final pref = SharedPreferencesAsync();
    await pref.setString(_settingsKey, jsonEncode(value.toJson()));
  }
}