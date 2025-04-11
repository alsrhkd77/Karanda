import 'package:flutter/material.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/enums/font.dart';
import 'package:karanda/model/app_settings.dart';
import 'package:karanda/model/audio_player_settings.dart';
import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/audio_player_repository.dart';
import 'package:karanda/repository/auth_repository.dart';
import 'package:karanda/model/user.dart';

class AppSettingsService {
  final AppSettingsRepository _appSettingsRepository;
  final AudioPlayerRepository _audioPlayerRepository;
  final AuthRepository _authRepository;

  AppSettingsService({
    required AppSettingsRepository settingsRepository,
    required AuthRepository authRepository,
    required AudioPlayerRepository audioPlayerRepository,
  })  : _appSettingsRepository = settingsRepository,
        _authRepository = authRepository,
        _audioPlayerRepository = audioPlayerRepository {
    _appSettingsRepository.getAppSettings();
  }

  Stream<AppSettings> get appSettingsStream =>
      _appSettingsRepository.settingsStream;

  Stream<AudioPlayerSettings> get audioPlayerSettingsStream => _audioPlayerRepository.settingsStream;

  Stream<User?> get userStream => _authRepository.userStream;

  BDORegion? get region => _appSettingsRepository.region;

  void setThemeMode(ThemeMode value) {
    _appSettingsRepository.setThemeMode(value);
  }

  void setFont(Font value) {
    _appSettingsRepository.setFont(value);
  }

  void setVolume(double value) {
    if (value < 0) {
      _audioPlayerRepository.setVolume(0);
    } else if (value > 100) {
      _audioPlayerRepository.setVolume(100);
    } else {
      _audioPlayerRepository.setVolume(value);
    }
  }

  void setRegion(BDORegion value) {
    _appSettingsRepository.setRegion(value);
  }
}
