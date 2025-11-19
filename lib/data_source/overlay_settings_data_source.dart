import 'dart:convert';

import 'package:karanda/enums/overlay_features.dart';
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
      if (!json.containsKey("position")){
        json["position"] = await _loadRect();
      }
      return OverlaySettings.fromJson(json);
    }
    return OverlaySettings(monitorDevice: primaryMonitor);
  }

  Future<void> saveSettings(OverlaySettings value) async {
    final pref = SharedPreferencesAsync();
    await pref.setString(_settingsKey, jsonEncode(value.toJson()));
  }

  // 구버전 호환용 각 오버레이 위젯 위치값
  Future<Map> _loadRect() async {
    final result = {};
    final pref = SharedPreferencesAsync();
    for(OverlayFeatures feature in OverlayFeatures.values) {
      final json = await pref.getString("${feature.name}-overlay-rect");
      if (json != null) {
        result[feature.name] = jsonDecode(json);
        pref.remove("$feature-overlay-rect");
      }
    }
    return result;
  }
}
