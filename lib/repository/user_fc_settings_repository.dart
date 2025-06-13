import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:karanda/data_source/user_fcm_settings_api.dart';
import 'package:karanda/model/user_fcm_settings.dart';

class UserFcmSettingsRepository {
  final UserFcmSettingsApi _userFcmSettingsApi;

  String? _token;

  UserFcmSettingsRepository({required UserFcmSettingsApi userFcmSettingsApi})
      : _userFcmSettingsApi = userFcmSettingsApi {
    if (kIsWeb || Platform.isAndroid) {
      _getToken();
    }
  }

  Future<void> _getToken() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.denied) {
      _token = await FirebaseMessaging.instance.getToken(
          vapidKey: kIsWeb ? const String.fromEnvironment('VAPID') : null);
    }
  }

  Future<UserFcmSettings?> getFcmSettings(String token) async {
    return await _userFcmSettingsApi.getSettings(token);
  }

  Future<UserFcmSettings> saveFcmSettings(UserFcmSettings value) async {
    return await _userFcmSettingsApi.saveSettings(value);
  }

  Future<void> unregisterToken(String token) async {
    await _userFcmSettingsApi.unregisterToken(token);
  }

  Future<void> updateFcmToken(String token) async {
    if (_token != null) {
      await _userFcmSettingsApi.updateFcmToken(_token!, token);
      _token = token;
    }
  }
}
