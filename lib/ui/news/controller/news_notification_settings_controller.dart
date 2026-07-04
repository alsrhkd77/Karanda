import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:karanda/enums/bdo_news_category.dart';
import 'package:karanda/model/bdo_news_notification_settings.dart';
import 'package:karanda/repository/bdo_news_repository.dart';
import 'package:karanda/service/app_settings_service.dart';
import 'package:karanda/service/bdo_news_service.dart';
import 'package:logging/logging.dart';

final _log = Logger('news');

/// 뉴스 알림 설정 상태. 값 변경 시 동작은 [BdoNewsService]가 플랫폼별로 분기한다.
class NewsNotificationSettingsController extends ChangeNotifier {
  final BdoNewsService _bdoNewsService;
  final BdoNewsRepository _bdoNewsRepository;
  final AppSettingsService _appSettingsService;
  late final StreamSubscription _settings;

  BdoNewsNotificationSettings? settings;

  NewsNotificationSettingsController({
    required BdoNewsService bdoNewsService,
    required BdoNewsRepository bdoNewsRepository,
    required AppSettingsService appSettingsService,
  })  : _bdoNewsService = bdoNewsService,
        _bdoNewsRepository = bdoNewsRepository,
        _appSettingsService = appSettingsService {
    _settings = _bdoNewsRepository.settingsStream.listen(_onSettingsUpdate);
    if (kIsWeb) {
      _loadWebSettings();
    }
  }

  /// (Web) 서버 저장 값이 원본이므로 페이지 로드 시 서버 설정을 UI에 반영
  Future<void> _loadWebSettings() async {
    try {
      final fcmSettings = await _appSettingsService.getFcmSettings();
      if (fcmSettings == null) return;
      final value = _bdoNewsRepository.settings
        ..notify = fcmSettings.newsNotify
        ..categories.clear()
        ..categories.addAll(fcmSettings.newsCategories);
      await _bdoNewsRepository.updateSettings(value);
    } catch (e, s) {
      _log.warning('Failed to load news notification settings from server', e, s);
    }
  }

  Future<void> setNotify(bool value) async {
    try {
      await _bdoNewsService.setNotify(value);
    } catch (e, s) {
      _log.warning('Failed to update news notify setting', e, s);
    }
  }

  Future<void> toggleCategory(BdoNewsCategory value) async {
    try {
      await _bdoNewsService.toggleCategory(value);
    } catch (e, s) {
      _log.warning('Failed to update news category setting', e, s);
    }
  }

  /// Windows에는 푸시 권한 개념이 없으므로 항상 사용 가능
  bool get available => !kIsWeb && Platform.isWindows || settings != null;

  void _onSettingsUpdate(BdoNewsNotificationSettings value) {
    settings = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _settings.cancel();
    super.dispose();
  }
}
