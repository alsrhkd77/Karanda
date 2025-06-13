import 'dart:convert';

import 'package:karanda/model/user_fcm_settings.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';
import 'package:karanda/utils/http_status.dart';
import 'package:karanda/utils/rest_client.dart';

class UserFcmSettingsApi {
  Future<UserFcmSettings?> getSettings(String token) async {
    final response = await RestClient.get(
      KarandaApi.getUserFcmSettings,
      parameters: {"token": token},
    );
    if (response.statusCode == HttpStatus.ok) {
      return UserFcmSettings.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == HttpStatus.noContent) {
      return null;
    }
    throw Exception("Failed to get user FCM settings");
  }

  Future<UserFcmSettings> saveSettings(UserFcmSettings value) async {
    final response = await RestClient.post(
      KarandaApi.saveUserFcmSettings,
      json: true,
      body: jsonEncode(value.toJson()),
    );
    if (response.statusCode == HttpStatus.ok) {
      return UserFcmSettings.fromJson(jsonDecode(response.body));
    }
    throw Exception("Failed to save user FCM settings");
  }

  Future<void> unregisterToken(String token) async {
    final response = await RestClient.delete(
      KarandaApi.deleteFcmToken,
      body: {"token": token},
    );
    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to delete FCM token");
    }
  }

  Future<void> updateFcmToken(String oldToken, String newToken) async {
    final response = await RestClient.patch(
      KarandaApi.updateFcmToken,
      body: {"oldToken": oldToken, "newToken": newToken},
    );
    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to update FCM token");
    }
  }
}
