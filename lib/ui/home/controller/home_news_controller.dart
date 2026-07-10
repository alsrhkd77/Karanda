import 'dart:async';

import 'package:flutter/material.dart';
import 'package:karanda/enums/bdo_news_category.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/bdo_news.dart';
import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/bdo_news_repository.dart';
import 'package:logging/logging.dart';

final _log = Logger('news');

/// 홈 화면 뉴스 섹션 상태 (highlights + 이벤트).
///
/// 이벤트는 마감 임박(D-3 이하) 항목이 있으면 그것을 우선 표시하고,
/// 없으면 최신 상위 [_maxEvents]건을 표시한다(레거시 동작).
class HomeNewsController extends ChangeNotifier {
  final BdoNewsRepository _bdoNewsRepository;
  final AppSettingsRepository _appSettingsRepository;
  late final StreamSubscription _region;

  static const int _maxEvents = 5;

  /// 마감 임박 기준 — 남은 일수가 이 값 이하면 임박으로 본다.
  static const int _nearDeadlineDays = 3;

  BdoNewsHighlights? highlights;
  List<BdoNews>? _events;

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

  /// 마감 임박 이벤트가 하나라도 있는지 (섹션 제목 분기에 사용)
  bool get isNearDeadline =>
      _events != null && _nearDeadlineEvents(_events!).isNotEmpty;

  /// 표시할 이벤트: 마감 임박(D-3 이하)이 있으면 마감 임박순, 없으면 최신 상위 N건
  List<BdoNews>? get events {
    final all = _events;
    if (all == null) return null;
    final near = _nearDeadlineEvents(all);
    if (near.isNotEmpty) return near.take(_maxEvents).toList();
    return all.take(_maxEvents).toList();
  }

  /// 진행 중이면서 남은 일수가 [_nearDeadlineDays] 이하인 이벤트를 마감 임박순으로.
  List<BdoNews> _nearDeadlineEvents(List<BdoNews> all) {
    final list = all.where((event) {
      final days = event.daysUntilDeadline;
      return days != null && days > 0 && days <= _nearDeadlineDays;
    }).toList();
    list.sort((a, b) => a.deadline!.compareTo(b.deadline!));
    return list;
  }

  Future<void> load() async {
    try {
      highlights = await _bdoNewsRepository.getHighlights(region: appRegion);
      notifyListeners();
    } catch (e) {
      _log.fine('Failed to load news highlights: $e');
    }
    try {
      // 마감 임박 판별을 위해 전체 이벤트를 받아 두고, 표시 시점에 상위 N건을 고른다.
      _events = await _bdoNewsRepository.fetchNews(
        region: appRegion,
        category: BdoNewsCategory.event,
      );
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
