import 'dart:convert';

import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/enums/bdo_news_category.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/bdo_news.dart';
import 'package:karanda/model/bdo_news_notification_settings.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';
import 'package:karanda/utils/http_status.dart';
import 'package:karanda/utils/rest_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BdoNewsApi {
  final String _settingsKey = "bdo-news-notification-settings";

  /// 뉴스 목록 조회 (페이징 없음, published_at 내림차순)
  Future<List<BdoNews>> getNews({
    required BDORegion region,
    BdoNewsCategory? category,
  }) async {
    final response = await RestClient.get(
      KarandaApi.bdoNews,
      parameters: {
        "region": region.name,
        if (category != null) "category": category.serverName,
      },
    );
    if (response.statusCode == HttpStatus.ok) {
      final List data = jsonDecode(response.bodyUTF);
      return data.map((json) => BdoNews.fromJson(json)).toList();
    }
    throw Exception("Failed to get bdo news");
  }

  /// 홈 화면용 주요 뉴스 조회
  Future<BdoNewsHighlights> getHighlights({required BDORegion region}) async {
    final response = await RestClient.get(
      KarandaApi.bdoNewsHighlights,
      parameters: {"region": region.name},
    );
    if (response.statusCode == HttpStatus.ok) {
      return BdoNewsHighlights.fromJson(jsonDecode(response.bodyUTF));
    }
    throw Exception("Failed to get bdo news highlights");
  }

  /// 뉴스 알림 설정 서버 저장 (Web 전용, 로그인 필요)
  Future<void> saveNewsNotificationSettings({
    required String token,
    required bool notify,
    required Set<BdoNewsCategory> categories,
  }) async {
    final response = await RestClient.patch(
      KarandaApi.saveNewsNotificationSettings,
      json: true,
      body: jsonEncode({
        "token": token,
        "newsNotify": notify,
        "newsCategories": categories.map((value) => value.serverName).toList(),
      }),
    );
    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to save news notification settings");
    }
  }

  /// 로컬 알림 설정 로드 (Windows·Android, Web은 UI 캐시)
  Future<BdoNewsNotificationSettings> loadNotificationSettings() async {
    final pref = SharedPreferencesAsync();
    final data = await pref.getString(_settingsKey);
    if (data != null) {
      return BdoNewsNotificationSettings.fromJson(jsonDecode(data));
    }
    return BdoNewsNotificationSettings();
  }

  /// 로컬 알림 설정 저장
  Future<void> saveNotificationSettings(
    BdoNewsNotificationSettings value,
  ) async {
    final pref = SharedPreferencesAsync();
    await pref.setString(_settingsKey, jsonEncode(value.toJson()));
  }
}
