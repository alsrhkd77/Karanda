import 'dart:convert';

import 'package:karanda/data_source/bdo_news_api.dart';
import 'package:karanda/data_source/web_socket_manager.dart';
import 'package:karanda/enums/bdo_news_action.dart';
import 'package:karanda/enums/bdo_news_category.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/bdo_news.dart';
import 'package:karanda/model/bdo_news_notification_settings.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// 뉴스 실시간 처리 운영 로그.
final _log = Logger('news');

/// 뉴스 데이터 접근 + 실시간 스트림 통합.
///
/// - [newsStream]: 마지막으로 로드한 필터(리전·카테고리)의 목록 캐시
/// - [realtimeMessageStream]: STOMP/FCM으로 수신한 실시간 뉴스 (알림 표시용)
/// - [settingsStream]: 뉴스 알림 설정 (플랫폼별 활용은 BdoNewsService 참고)
class BdoNewsRepository {
  final WebSocketManager _webSocketManager;
  final BdoNewsApi _bdoNewsApi;
  final _news = BehaviorSubject<List<BdoNews>>();
  final _realtimeMessages = PublishSubject<BdoNewsMessage>();
  final _settings = BehaviorSubject<BdoNewsNotificationSettings>();

  /// 현재 목록 캐시가 어떤 조건으로 로드됐는지 (실시간 반영 필터링용)
  BDORegion? _loadedRegion;
  BdoNewsCategory? _loadedCategory;

  static const List<BdoNewsCategory> _regionCategories = [
    BdoNewsCategory.notice,
    BdoNewsCategory.update,
    BdoNewsCategory.event,
  ];

  BdoNewsRepository({
    required WebSocketManager webSocketManager,
    required BdoNewsApi bdoNewsApi,
  })  : _webSocketManager = webSocketManager,
        _bdoNewsApi = bdoNewsApi {
    loadSettings();
  }

  Stream<List<BdoNews>> get newsStream => _news.stream;

  Stream<BdoNewsMessage> get realtimeMessageStream => _realtimeMessages.stream;

  Stream<BdoNewsNotificationSettings> get settingsStream => _settings.stream;

  BdoNewsNotificationSettings get settings =>
      _settings.valueOrNull ?? BdoNewsNotificationSettings();

  /* ---------------- 목록 ---------------- */

  Future<void> loadNews({
    required BDORegion region,
    BdoNewsCategory? category,
  }) async {
    final result = await _bdoNewsApi.getNews(region: region, category: category);
    _loadedRegion = region;
    _loadedCategory = category;
    _news.sink.add(result);
  }

  Future<BdoNewsHighlights> getHighlights({required BDORegion region}) {
    return _bdoNewsApi.getHighlights(region: region);
  }

  /// 목록 캐시([newsStream])에 영향을 주지 않는 단발 조회 (홈 화면 등)
  Future<List<BdoNews>> fetchNews({
    required BDORegion region,
    BdoNewsCategory? category,
  }) {
    return _bdoNewsApi.getNews(region: region, category: category);
  }

  /// 실시간 CREATED 반영 — 현재 로드된 필터에 맞는 뉴스만 캐시 맨 앞에 추가
  void applyCreated(BdoNews news) {
    if (!_matchesLoadedFilter(news)) return;
    final snapshot = _news.valueOrNull;
    if (snapshot == null) return;
    if (snapshot.any((element) => element.id == news.id)) return;
    _news.sink.add([news, ...snapshot]);
  }

  /// 실시간 UPDATED 반영 — 동일 id 항목의 deadline 갱신 (없으면 무시)
  void applyUpdated(String id, DateTime? deadline) {
    final snapshot = _news.valueOrNull;
    if (snapshot == null) return;
    final index = snapshot.indexWhere((element) => element.id == id);
    if (index < 0) return;
    snapshot[index].deadline = deadline;
    _news.sink.add(snapshot);
  }

  bool _matchesLoadedFilter(BdoNews news) {
    if (_loadedRegion == null) return false;
    if (news.region != _loadedRegion) return false;
    return _loadedCategory == null || news.category == _loadedCategory;
  }

  /* ---------------- 실시간 채널 (Windows STOMP) ---------------- */

  /// 앱 설정 리전의 NOTICE/UPDATE/EVENT destination 구독.
  /// 리전 변경 시 [disconnectRegionNewsChannels] 후 재호출한다.
  void connectRegionNewsChannels(BDORegion region) {
    for (final category in _regionCategories) {
      _webSocketManager.register(
        destination: "/bdo-news/REGION/${category.serverName}",
        region: region,
        callback: _onMessage,
      );
    }
  }

  void disconnectRegionNewsChannels() {
    for (final category in _regionCategories) {
      _webSocketManager.unregister(
        destination: "/bdo-news/REGION/${category.serverName}",
      );
    }
  }

  /// LAB destination 구독 — 리전 무관이므로 앱 실행 중 1회만 등록한다.
  /// (WebSocketManager는 같은 destination 재등록 시 이전 구독을 해제하지 않으므로
  /// 리전 변경 때마다 재등록하면 브로커에 구독이 누적된다.)
  void connectLabNewsChannel() {
    _webSocketManager.register(
      destination: "/bdo-news/LAB",
      callback: _onMessage,
    );
  }

  void _onMessage(StompFrame frame) {
    if (frame.body?.isNotEmpty ?? false) {
      try {
        final message = BdoNewsMessage.fromJson(jsonDecode(frame.body!));
        applyRealtimeMessage(message);
      } catch (e, s) {
        // 잘못된 형식의 프레임이 실시간 처리를 중단시키지 않도록 방어
        _log.warning('Failed to parse news realtime frame', e, s);
      }
    }
  }

  /// 실시간 메시지 공통 처리 (STOMP·FCM 공용) — 캐시 갱신 + 스트림 발행
  void applyRealtimeMessage(BdoNewsMessage message) {
    switch (message.action) {
      case BdoNewsAction.created:
        applyCreated(message.news);
      case BdoNewsAction.updated:
        applyUpdated(message.news.id, message.news.deadline);
    }
    _realtimeMessages.sink.add(message);
  }

  /* ---------------- 알림 설정 ---------------- */

  Future<void> loadSettings() async {
    final value = await _bdoNewsApi.loadNotificationSettings();
    _settings.sink.add(value);
  }

  Future<void> updateSettings(BdoNewsNotificationSettings value) async {
    _settings.sink.add(value);
    await _bdoNewsApi.saveNotificationSettings(value);
  }

  /// (Web) 뉴스 알림 설정 서버 저장
  Future<void> saveNewsNotificationSettings({
    required String token,
    required bool notify,
    required Set<BdoNewsCategory> categories,
  }) {
    return _bdoNewsApi.saveNewsNotificationSettings(
      token: token,
      notify: notify,
      categories: categories,
    );
  }
}
