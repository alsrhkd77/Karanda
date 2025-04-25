import 'dart:convert';

import 'package:karanda/model/overlay_settings.dart';
import 'package:karanda/utils/overlay_window_utils/overlay_window_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverlaySettingsDataSource {
  final String _settingsKey = "overlay-settings";

  Future<OverlaySettings> loadSettings() async {
    final pref = SharedPreferencesAsync();
    final data = await pref.getString(_settingsKey);
    final primaryMonitor = await OverlayWindowUtils().getPrimaryMonitorDevice();
    if (data != null) {
      final Map json = jsonDecode(data);
      if (!json.containsKey("monitorDevice")) {
        json["monitorDevice"] = primaryMonitor.toJson();
      }
      return OverlaySettings.fromJson(json);
    }
    return OverlaySettings(monitorDevice: primaryMonitor);
  }

  Future<void> saveSettings(OverlaySettings value) async {
    final pref = SharedPreferencesAsync();
    await pref.setString(_settingsKey, jsonEncode(value.toJson()));
  }
}
