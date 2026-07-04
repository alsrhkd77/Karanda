import 'dart:async';

import 'package:flutter/material.dart';
import 'package:karanda/enums/bdo_news_category.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/bdo_news.dart';
import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/bdo_news_repository.dart';
import 'package:logging/logging.dart';

final _log = Logger('news');

/// 홈 화면 뉴스 섹션 상태 (highlights + 이벤트 상위 5건)
class HomeNewsController extends ChangeNotifier {
  final BdoNewsRepository _bdoNewsRepository;
  final AppSettingsRepository _appSettingsRepository;
  late final StreamSubscription _region;

  static const int _maxEvents = 5;

  BdoNewsHighlights? highlights;
  List<BdoNews>? events;

  HomeNewsController({
    required BdoNewsRepository bdoNewsRepository,
    required AppSettingsRepository appSettingsRepository,
  })  : _bdoNewsRepository = bdoNewsRepository,
        _appSettingsRepository = appSettingsRepository {
    _region = _appSettingsRepository.settingsStream
        .map((value) => value.region)
        .distinct()
        .listen((_) => load());
  }

  BDORegion get appRegion => _appSettingsRepository.region ?? BDORegion.KR;

  Future<void> load() async {
    try {
      highlights = await _bdoNewsRepository.getHighlights(region: appRegion);
      notifyListeners();
    } catch (e) {
      _log.fine('Failed to load news highlights: $e');
    }
    try {
      // 페이징 파라미터가 없으므로 전체 응답에서 앞부분만 사용
      final result = await _bdoNewsRepository.fetchNews(
        region: appRegion,
        category: BdoNewsCategory.event,
      );
      events = result.take(_maxEvents).toList();
      notifyListeners();
    } catch (e) {
      _log.fine('Failed to load news events: $e');
    }
  }

  @override
  void dispose() {
    _region.cancel();
    super.dispose();
  }
}
