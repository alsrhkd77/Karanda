import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/enums/font.dart';
import 'package:karanda/model/app_settings.dart';
import 'package:karanda/model/audio_player_settings.dart';
import 'package:karanda/model/user_fcm_settings.dart';
import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/audio_player_repository.dart';
import 'package:karanda/repository/auth_repository.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/repository/user_fc_settings_repository.dart';
import 'dart:developer' as developer;

class AppSettingsService {
  final AppSettingsRepository _appSettingsRepository;
  final AudioPlayerRepository _audioPlayerRepository;
  final AuthRepository _authRepository;
  final UserFcmSettingsRepository _userFcmSettingsRepository;

  AppSettingsService({
    required AppSettingsRepository settingsRepository,
    required AuthRepository authRepository,
    required AudioPlayerRepository audioPlayerRepository,
    required UserFcmSettingsRepository userFcmSettingsRepository,
  })  : _appSettingsRepository = settingsRepository,
        _authRepository = authRepository,
        _audioPlayerRepository = audioPlayerRepository,
        _userFcmSettingsRepository = userFcmSettingsRepository {
    //_appSettingsRepository.getAppSettings();
    if (kIsWeb || Platform.isAndroid) {
      FirebaseMessaging.instance.onTokenRefresh.listen(_onFcmTokenRefresh);
      _appSettingsRepository.settingsStream
          .map((item) => item.region)
          .distinct()
          .listen(_onRegionUpdate);
    }
  }

  Stream<AppSettings> get appSettingsStream =>
      _appSettingsRepository.settingsStream;

  Stream<AudioPlayerSettings> get audioPlayerSettingsStream =>
      _audioPlayerRepository.settingsStream;

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

  void setStartMinimized(bool value) {
    _appSettingsRepository.setStartMinimized(value);
  }

  void setUseTrayMode(bool value) {
    _appSettingsRepository.setUseTrayMode(value);
  }

  void _onFcmTokenRefresh(String value) {
    _userFcmSettingsRepository.updateFcmToken(value);
  }

  Future<void> _onRegionUpdate(BDORegion value) async {
    if (_authRepository.authenticated && (kIsWeb || Platform.isAndroid)) {
      try {
        final token = await FirebaseMessaging.instance.getToken(
          vapidKey: kIsWeb ? const String.fromEnvironment('VAPID') : null,
        );
        if (token != null) {
          final fcmSettings =
              await _userFcmSettingsRepository.getFcmSettings(token);
          fcmSettings?.region = value;
          if (fcmSettings != null) {
            await _userFcmSettingsRepository.saveFcmSettings(fcmSettings);
          }
        }
      } catch (e) {
        developer.log(e.toString());
      }
    }
  }

  Future<UserFcmSettings?> activatePushNotification() async {
    try {
      final notificationSettings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      if (notificationSettings.authorizationStatus ==
          AuthorizationStatus.denied) {
        return null;
      } else {
        final token = await FirebaseMessaging.instance.getToken(
          vapidKey: kIsWeb ? const String.fromEnvironment('VAPID') : null,
        );
        if (token == null) {
          return null;
        } else {
          return await _userFcmSettingsRepository
              .saveFcmSettings(UserFcmSettings(
            token: token,
            region: region ?? BDORegion.values.first,
          ));
        }
      }
    } catch (e) {
      developer.log(e.toString());
      return null;
    }
  }

  Future<void> deactivatePushNotification() async {
    final token = await FirebaseMessaging.instance.getToken(
      vapidKey: kIsWeb ? const String.fromEnvironment('VAPID') : null,
    );
    if (token != null) {
      await _userFcmSettingsRepository.unregisterToken(token);
    }
  }

  Future<UserFcmSettings?> getFcmSettings() async {
    try {
      final notificationSettings =
          await FirebaseMessaging.instance.getNotificationSettings();
      if (notificationSettings.authorizationStatus !=
          AuthorizationStatus.denied) {
        final token = await FirebaseMessaging.instance.getToken(
          vapidKey: kIsWeb ? const String.fromEnvironment('VAPID') : null,
        );
        if (token != null) {
          return await _userFcmSettingsRepository.getFcmSettings(token);
        }
      }
    } catch (e) {
      developer.log(e.toString());
      return null;
    }
    return null;
  }

  Future<UserFcmSettings> saveFcmSettings(UserFcmSettings value) async {
    if (region != null) {
      value.region = region!;
    }
    return await _userFcmSettingsRepository.saveFcmSettings(value);
  }
}
