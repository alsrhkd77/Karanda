import 'dart:convert';

import 'package:karanda/model/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsDataSource {
  final String _key = "app-settings";

  Future<AppSettings?> load() async {
    final pref = SharedPreferencesAsync();
    final data = await pref.getString(_key);
    if(data != null){
      return AppSettings.fromJson(jsonDecode(data));
    }
    return null;
  }

  Future<void> save(AppSettings settings) async {
    final pref = SharedPreferencesAsync();
    await pref.setString(_key, jsonEncode(settings.toJson()));
  }
}
