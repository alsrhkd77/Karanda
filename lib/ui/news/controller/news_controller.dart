import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/enums/bdo_news_action.dart';
import 'package:karanda/enums/bdo_news_category.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/bdo_news.dart';
import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/bdo_news_repository.dart';

/// 이벤트 목록 정렬 기준
enum EventSort { registered, deadline }

/// 뉴스 페이지 상태.
///
/// - 주요 업데이트 1건 / 연구소 최신 1건: highlights (단발 조회, null이면 섹션 숨김)
/// - 이벤트 목록: repository 캐시([BdoNewsRepository.newsStream])로 로드해
///   실시간 CREATED/UPDATED를 반영하고, 정렬·상시 포함 여부는 로컬에서 처리한다.
class NewsController extends ChangeNotifier {
  final BdoNewsRepository _bdoNewsRepository;
  final AppSettingsRepository _appSettingsRepository;
  late final StreamSubscription _news;
  late final StreamSubscription _region;
  late final StreamSubscription _realtime;

  BdoNewsHighlights? _highlights;
  List<BdoNews>? _events;
  bool failed = false;

  EventSort _eventSort = EventSort.registered;
  bool _includeAlways = true;

  NewsController({
    required BdoNewsRepository bdoNewsRepository,
    required AppSettingsRepository appSettingsRepository,
  })  : _bdoNewsRepository = bdoNewsRepository,
        _appSettingsRepository = appSettingsRepository {
    _news = _bdoNewsRepository.newsStream.listen(_onEventsUpdate);
    _region = _appSettingsRepository.settingsStream
        .map((value) => value.region)
        .distinct()
        .listen((_) => loadNews());
    // 이벤트 목록은 캐시(newsStream)로 실시간 반영되지만, 하이라이트(주요 업데이트/연구소)는
    // 단발 조회이므로 실시간 메시지를 직접 구독해 최신 항목으로 교체한다.
    _realtime =
        _bdoNewsRepository.realtimeMessageStream.listen(_onRealtimeMessage);
  }

  bool get loading => (_highlights == null || _events == null) && !failed;

  BDORegion get appRegion => _appSettingsRepository.region ?? BDORegion.KR;

  BdoNews? get majorUpdate => _highlights?.latestMajorUpdate;

  BdoNews? get labUpdate => _highlights?.latestLabUpdate;

  EventSort get eventSort => _eventSort;

  bool get includeAlways => _includeAlways;

  /// 정렬·상시 포함 필터가 적용된 이벤트 목록
  List<BdoNews> get events {
    var result = List<BdoNews>.from(_events ?? const []);
    if (!_includeAlways) {
      result = result.where((event) => event.deadline != null).toList();
    }
    switch (_eventSort) {
      case EventSort.registered:
        result.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      case EventSort.deadline:
        result.sort(_byDeadline);
    }
    return result;
  }

  Future<void> loadNews() async {
    try {
      failed = false;
      // 이미 로드된 데이터는 유지한다(pull-to-refresh 시 목록이 사라지지 않도록).
      // 이벤트 목록은 repository 캐시(newsStream)로 로드 → _onEventsUpdate 로 반영.
      final highlightsFuture =
          _bdoNewsRepository.getHighlights(region: appRegion);
      await _bdoNewsRepository.loadNews(
        region: appRegion,
        category: BdoNewsCategory.event,
      );
      _highlights = await highlightsFuture;
      notifyListeners();
    } catch (_) {
      failed = true;
      notifyListeners();
    }
  }

  void setEventSort(EventSort value) {
    if (_eventSort == value) return;
    _eventSort = value;
    notifyListeners();
  }

  void toggleIncludeAlways() {
    _includeAlways = !_includeAlways;
    notifyListeners();
  }

  /// 마감일순: 진행 중(마감 임박순) → 종료(최근 종료순) → 상시(최신순)
  int _byDeadline(BdoNews a, BdoNews b) {
    final ra = _deadlineRank(a);
    final rb = _deadlineRank(b);
    if (ra != rb) return ra - rb;
    switch (ra) {
      case 0:
        return a.deadline!.compareTo(b.deadline!); // 진행 중: 마감 임박순
      case 1:
        return b.deadline!.compareTo(a.deadline!); // 종료: 최근 종료순
      default:
        return b.publishedAt.compareTo(a.publishedAt); // 상시: 최신순
    }
  }

  int _deadlineRank(BdoNews event) {
    if (event.deadline == null) return 2; // 상시 → 맨 아래
    return event.daysUntilDeadline! > 0 ? 0 : 1; // 진행 중(0) → 종료(1)
  }

  void _onEventsUpdate(List<BdoNews> value) {
    _events = value;
    notifyListeners();
  }

  /// 실시간 CREATED 메시지로 하이라이트(주요 업데이트/연구소)를 최신 항목으로 교체.
  /// (이벤트는 캐시로 이미 반영되므로 여기서는 다루지 않는다.)
  void _onRealtimeMessage(BdoNewsMessage message) {
    if (message.action != BdoNewsAction.created) return;
    final current = _highlights;
    if (current == null) return; // 초기 로드 전이면 무시(로드가 최신값을 가져옴)

    final news = message.news;
    // 주요 업데이트: 앱 설정 리전의 is_major UPDATE
    if (news.category == BdoNewsCategory.update &&
        news.region == appRegion &&
        news.isMajor &&
        _isNewer(news, current.latestMajorUpdate)) {
      _highlights = BdoNewsHighlights(
        latestMajorUpdate: news,
        latestLabUpdate: current.latestLabUpdate,
      );
      notifyListeners();
    } else if (news.category == BdoNewsCategory.lab &&
        _isNewer(news, current.latestLabUpdate)) {
      // 연구소: 리전 무관
      _highlights = BdoNewsHighlights(
        latestMajorUpdate: current.latestMajorUpdate,
        latestLabUpdate: news,
      );
      notifyListeners();
    }
  }

  bool _isNewer(BdoNews incoming, BdoNews? current) {
    if (current == null) return true;
    if (incoming.id == current.id) return false; // 동일 항목이면 갱신 불필요
    return !incoming.publishedAt.isBefore(current.publishedAt);
  }

  @override
  void dispose() {
    _news.cancel();
    _region.cancel();
    _realtime.cancel();
    super.dispose();
  }
}
