import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:karanda/data_source/bdo_news_topic_subscriber.dart';
import 'package:karanda/enums/bdo_news_action.dart';
import 'package:karanda/enums/bdo_news_category.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/enums/features.dart';
import 'package:karanda/model/app_notification_message.dart';
import 'package:karanda/model/bdo_news.dart';
import 'package:karanda/model/bdo_news_notification_settings.dart';
import 'package:karanda/repository/app_notification_repository.dart';
import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/bdo_news_repository.dart';
import 'package:karanda/utils/launch_url.dart';
import 'package:logging/logging.dart';

/// 뉴스 실시간 수신·알림 운영 로그. FCM 토큰 값은 절대 기록하지 않는다.
final _log = Logger('news');

/// 뉴스 실시간 수신과 알림 설정의 플랫폼 분기를 담당하는 서비스.
///
/// | 플랫폼 | 수신 | 알림 설정 변경 시 |
/// |--------|------|------------------|
/// | Windows | STOMP 상시 구독 (캐시 갱신) + 로컬 설정 필터로 토스트 | 로컬 저장만 |
/// | Android | FCM 토픽 (백그라운드는 시스템 알림 자동 표시) | 토픽 구독/해제 + 로컬 저장 |
/// | Web | FCM 토큰 개별 발송 (서버가 설정 기반 필터) | 서버 저장 + 로컬 캐시 |
class BdoNewsService {
  final BdoNewsRepository _bdoNewsRepository;
  final AppNotificationRepository _appNotificationRepository;
  final AppSettingsRepository _appSettingsRepository;
  final BdoNewsTopicSubscriber _topicSubscriber;

  /// (Windows) LAB 채널 최초 1회 구독 여부
  bool _labChannelConnected = false;

  BdoNewsService({
    required BdoNewsRepository bdoNewsRepository,
    required AppNotificationRepository appNotificationRepository,
    required AppSettingsRepository appSettingsRepository,
    required BdoNewsTopicSubscriber topicSubscriber,
  })  : _bdoNewsRepository = bdoNewsRepository,
        _appNotificationRepository = appNotificationRepository,
        _appSettingsRepository = appSettingsRepository,
        _topicSubscriber = topicSubscriber {
    if (!kIsWeb && Platform.isWindows) {
      // STOMP는 캐시 갱신을 위해 상시 구독하고, 토스트만 설정으로 거른다.
      // WebSocket 연결은 다른 실시간 기능과 동일하게 생성자가 아니라 설정 스트림
      // 콜백(빌드 이후)에서 시작한다 — 초기화 프레임 도중 소켓 활성화를 피하기 위함.
      _appSettingsRepository.settingsStream
          .map((value) => value.region)
          .distinct()
          .listen(_onRegionUpdateWindows);
      _bdoNewsRepository.realtimeMessageStream.listen(_onStompMessage);
    } else if (kIsWeb || Platform.isAndroid) {
      FirebaseMessaging.onMessage.listen(_onFcmMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onFcmMessageOpened);
      if (!kIsWeb && Platform.isAndroid) {
        // 앱 시작(첫 발행) 시 로컬 설정 기준 재구독 + 리전 변경 시 토픽 재구독
        _appSettingsRepository.settingsStream
            .map((value) => value.region)
            .distinct()
            .listen(_onRegionUpdateAndroid);
      }
    }
  }

  /* ---------------- Windows (STOMP) ---------------- */

  void _onRegionUpdateWindows(BDORegion region) {
    // LAB은 리전 무관이므로 최초 설정 emit 시 1회만 구독한다.
    if (!_labChannelConnected) {
      _bdoNewsRepository.connectLabNewsChannel();
      _labChannelConnected = true;
    }
    _bdoNewsRepository.disconnectRegionNewsChannels();
    _bdoNewsRepository.connectRegionNewsChannels(region);
  }

  void _onStompMessage(BdoNewsMessage message) {
    final settings = _bdoNewsRepository.settings;
    if (!settings.notify ||
        !settings.categories.contains(message.news.category)) {
      return;
    }
    _showToast(message);
  }

  /* ---------------- Web · Android (FCM) ---------------- */

  void _onFcmMessage(RemoteMessage message) {
    if (message.data["type"] != "BDO_NEWS") return;
    try {
      final newsMessage = BdoNewsMessage.fromFcmData(message.data);
      _log.info('News received (${newsMessage.news.id})');
      // 포그라운드 수신 — 캐시 갱신 + 인앱 토스트
      // (수신 자체가 구독/서버 필터를 통과한 것이므로 별도 필터 없이 표시)
      _bdoNewsRepository.applyRealtimeMessage(newsMessage);
      _showToast(newsMessage);
    } catch (e, s) {
      _log.warning('Failed to handle news FCM message', e, s);
    }
  }

  void _onFcmMessageOpened(RemoteMessage message) {
    if (message.data["type"] != "BDO_NEWS") return;
    try {
      final news = BdoNews.fromFcmData(message.data);
      launchURL(news.resolveUrl(_appSettingsRepository.region ?? BDORegion.KR));
    } catch (e, s) {
      _log.warning('Failed to open news from notification', e, s);
    }
  }

  /* ---------------- 토스트 ---------------- */

  void _showToast(BdoNewsMessage message) {
    _appNotificationRepository.addNotification(_toNotification(message));
  }

  AppNotificationMessage _toNotification(BdoNewsMessage message) {
    if (message.action == BdoNewsAction.updated) {
      return AppNotificationMessage(
        feature: Features.news,
        contentsKey: "eventNewsExtended",
        contentsArgs: [
          message.news.title,
          _formatDate(message.news.deadline),
        ],
        route: "/news",
        mdContents: false,
      );
    }
    return AppNotificationMessage(
      feature: Features.news,
      contentsKey: "${message.news.category.name}NewsCreated",
      contentsArgs: [message.news.title],
      route: "/news",
      mdContents: false,
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return "-";
    return "${value.year}."
        "${value.month.toString().padLeft(2, '0')}."
        "${value.day.toString().padLeft(2, '0')}";
  }

  /* ---------------- 알림 설정 ---------------- */

  Future<void> setNotify(bool value) async {
    _log.info('Setting changed: news notify = $value');
    final snapshot = _bdoNewsRepository.settings..notify = value;
    await _applySettings(snapshot);
  }

  Future<void> toggleCategory(BdoNewsCategory value) async {
    final snapshot = _bdoNewsRepository.settings;
    if (!snapshot.categories.remove(value)) {
      snapshot.categories.add(value);
    }
    _log.info('Setting changed: news categories = '
        '${snapshot.categories.map((item) => item.name).join(",")}');
    await _applySettings(snapshot);
  }

  Future<void> _applySettings(BdoNewsNotificationSettings value) async {
    if (!kIsWeb && Platform.isAndroid) {
      await _syncTopicSubscriptions(value);
    } else if (kIsWeb) {
      await _saveSettingsToServer(value);
    }
    await _bdoNewsRepository.updateSettings(value);
  }

  /// (Android) 로컬 설정과 FCM 토픽 구독 상태를 일치시킨다.
  /// 구독/해제는 멱등이므로 앱 시작·토큰 재발급 후 재실행해도 안전하다.
  Future<void> _syncTopicSubscriptions(
    BdoNewsNotificationSettings value,
  ) async {
    final region = _appSettingsRepository.region ?? BDORegion.KR;
    // 리전이 바뀐 경우 이전 리전 토픽 해제 (news_LAB은 리전 무관)
    if (value.subscribedRegion != null && value.subscribedRegion != region) {
      for (final category in BdoNewsCategory.values) {
        if (category == BdoNewsCategory.lab) continue;
        await _topicSubscriber.unsubscribe(
          _topicSubscriber.topicOf(value.subscribedRegion!, category),
        );
      }
    }
    for (final category in BdoNewsCategory.values) {
      final topic = _topicSubscriber.topicOf(region, category);
      if (value.notify && value.categories.contains(category)) {
        await _topicSubscriber.subscribe(topic);
      } else {
        await _topicSubscriber.unsubscribe(topic);
      }
    }
    value.subscribedRegion = region;
  }

  /// (Web) 뉴스 알림 설정을 서버에 저장 — 서버 저장 값이 발송 대상 판단의 원본
  Future<void> _saveSettingsToServer(
    BdoNewsNotificationSettings value,
  ) async {
    final token = await FirebaseMessaging.instance.getToken(
      vapidKey: const String.fromEnvironment('VAPID'),
    );
    if (token == null) {
      _log.warning('Cannot save news notification settings: no FCM token');
      return;
    }
    await _bdoNewsRepository.saveNewsNotificationSettings(
      token: token,
      notify: value.notify,
      categories: value.categories,
    );
  }

  void _onRegionUpdateAndroid(BDORegion region) async {
    try {
      // 설정 로드 완료를 보장한 뒤 현재 리전 기준으로 구독 동기화
      final settings = await _bdoNewsRepository.settingsStream.first;
      await _syncTopicSubscriptions(settings);
      await _bdoNewsRepository.updateSettings(settings);
    } catch (e, s) {
      _log.warning('Failed to sync news topic subscriptions', e, s);
    }
  }
}
