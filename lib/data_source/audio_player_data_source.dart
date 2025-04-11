import 'dart:convert';

import 'package:karanda/model/audio_player_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioPlayerDataSource {
  final String _settingsKey = "audio-player-settings";

  Future<void> saveSettings(AudioPlayerSettings settings) async {
    final pref = SharedPreferencesAsync();
    await pref.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<AudioPlayerSettings> loadSettings() async {
    final pref = SharedPreferencesAsync();
    final data = await pref.getString(_settingsKey);
    if(data != null){
      return AudioPlayerSettings.fromJson(jsonDecode(data));
    } else {
      return AudioPlayerSettings();
    }
  }
}