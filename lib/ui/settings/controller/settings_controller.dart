import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karanda/enums/font.dart';
import 'package:karanda/model/app_settings.dart';
import 'package:karanda/model/audio_player_settings.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/service/app_settings_service.dart';

class SettingsController extends ChangeNotifier {
  final AppSettingsService _settingsService;
  late final StreamSubscription<AppSettings> _appSettings;
  late final StreamSubscription<AudioPlayerSettings> _audioPlayerSettings;
  late final StreamSubscription<User?> _user;

  AppSettings appSettings = AppSettings();
  AudioPlayerSettings audioPlayerSettings = AudioPlayerSettings();
  User? user;

  SettingsController({required AppSettingsService settingsService})
      : _settingsService = settingsService {
    _appSettings =
        _settingsService.appSettingsStream.listen(_updateAppSettings);
    _audioPlayerSettings = _settingsService.audioPlayerSettingsStream
        .listen(_updateAudioPlayerSettings);
    _user = _settingsService.userStream.listen(_updateUser);
  }

  ThemeMode get themeMode => appSettings.themeMode;

  Font get font => appSettings.font;

  void setThemeMode(ThemeMode? value) {
    if (value != null) {
      _settingsService.setThemeMode(value);
    }
  }

  void setVolume(double value) {
    _settingsService.setVolume(value);
  }

  void setFont(Font? value) {
    if (value != null) {
      _settingsService.setFont(value);
    }
  }

  TextTheme? textTheme([TextTheme? base]) {
    switch (appSettings.font) {
      case (Font.notoSansKR):
        return GoogleFonts.notoSansKrTextTheme(base);
      case (Font.nanumGothic):
        return GoogleFonts.nanumGothicTextTheme(base);
      case (Font.jua):
        return GoogleFonts.juaTextTheme(base);
      default:
        return null;
    }
  }

  void _updateAppSettings(AppSettings value) {
    appSettings = value;
    notifyListeners();
  }

  void _updateAudioPlayerSettings(AudioPlayerSettings value) {
    audioPlayerSettings = value;
    notifyListeners();
  }

  void _updateUser(User? value) {
    user = value;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _audioPlayerSettings.cancel();
    await _appSettings.cancel();
    await _user.cancel();
    super.dispose();
  }
}
