import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';
import 'package:karanda/utils/token_utils.dart';
import 'package:logging/logging.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../utils/web_visibility/web_visibility.dart';

/// 실시간 통신(STOMP) 운영 로그. 인증 헤더·토큰은 절대 기록하지 않는다.
final _log = Logger('websocket');

class WebSocketManager {
  final WebVisibility _webVisibility = WebVisibility();
  final String _prefix = "/live-data";
  StompClient? _client;
  Timer? _reconnectTimer;
  int _backOff = 200;

  /// 사용자가 의도적으로 [deactivate]한 경우(웹 탭 숨김/구독 전부 해제)와
  /// 예상치 못한 연결 끊김을 구분한다. 의도적 종료 시에는 재연결하지 않는다.
  bool _intentionalClose = false;

  final Map<String, _Subscription> _subscription = {};

  WebSocketManager() {
    if (kIsWeb) {
      _webVisibility.debouncedStatusStream.listen((visible) {
        if (visible) {
          if (_subscription.isNotEmpty) {
            activate();
          }
        } else {
          deactivate();
        }
      });
    }
  }

  void activate() {
    _intentionalClose = false;
    if (_client == null || !_client!.connected) {
      // 예약된 재연결과 수동 activate가 겹쳐 클라이언트가 중복 생성되는 것을 방지
      _reconnectTimer?.cancel();
      _client = StompClient(config: _buildConfig());
      _client!.activate();
    }
  }

  void deactivate() {
    _intentionalClose = true;
    _reconnectTimer?.cancel();
    _client?.deactivate();
    _client = null;
  }

  /// 예상치 못한 연결 끊김(백엔드 다운 등)·연결 실패 공통 처리.
  /// 죽은 소켓에 프레임을 전송하지 않고(라이브러리가 heartbeat/소켓 정리를 수행하도록),
  /// 운영 로그를 남긴 뒤 지수 백오프로 재연결을 예약한다.
  void _handleUnexpectedDisconnect() {
    if (_intentionalClose) return;
    // onWebSocketError와 onWebSocketDone가 모두 발생해도 한 번만 예약(백오프 중복 증가 방지)
    if (_reconnectTimer?.isActive ?? false) return;
    _client = null;
    _backOff = min(_backOff * 2, 600000);
    _log.warning('Realtime server connection lost, reconnecting in ${_backOff}ms');
    _reconnectTimer = Timer(Duration(milliseconds: _backOff), activate);
  }

  Future<void> register({
    required String destination,
    BDORegion? region,
    required void Function(StompFrame message) callback,
  }) async {
    var unsubscribeFn = _client != null && _client!.isActive && _client!.connected
        ? await _subscribe(
            destination: destination,
            callback: callback,
            region: region,
          )
        : null;
    _subscription[destination] = _Subscription(
      destination: destination,
      region: region,
      callback: callback,
      unsubscribeFn: unsubscribeFn,
    );
    _log.info('Subscribe realtime channel: $destination'
        '${region == null ? '' : ' (region: ${region.name})'}');
    if (_subscription.length == 1) {
      activate();
    }
  }

  void unregister({required String destination}) {
    if (_subscription.containsKey(destination)) {
      if (_subscription[destination]!.unsubscribeFn != null) {
        _subscription[destination]!.unsubscribeFn!();
      }
      _subscription.remove(destination);
      _log.info('Unsubscribe realtime channel: $destination');
      if (_subscription.isEmpty) {
        deactivate();
      }
    }
  }

  Future<void Function({Map<String, String>? unsubscribeHeaders})?> _subscribe({
    required String destination,
    BDORegion? region,
    required void Function(StompFrame message) callback,
  }) async {
    if ((_client?.isActive ?? false) && (_client?.connected ?? false)) {
      Map<String, String> headers = {};
      const storage = FlutterSecureStorage();
      String? token = await storage.read(key: 'karanda-token');
      if (token != null) {
        headers.addAll({'Authorization': token});
      }
      headers.addAll({'Qualification': TokenUtils.serviceToken()});
      if (region != null) {
        destination = destination.replaceAll(
            "/REGION/", "/${region.name.toUpperCase()}/");
      }
      return _client?.subscribe(
        destination: _prefix + destination,
        headers: headers,
        callback: callback,
      );
    }
    return null;
  }

  StompConfig _buildConfig() {
    return StompConfig(
      url: KarandaApi.liveChannel,
      // 라이브러리 자동 재연결(기본 5초 고정)을 끄고, 자체 지수 백오프를 사용한다.
      // 죽은 소켓에 DISCONNECT 프레임을 보내지 않으므로 StompBadStateException이 발생하지 않고,
      // 라이브러리의 _cleanUp()이 정상 실행되어 heartbeat 타이머가 취소된다.
      reconnectDelay: Duration.zero,
      onWebSocketDone: _handleUnexpectedDisconnect,
      onWebSocketError: (error) {
        _log.fine('Realtime WebSocket error: $error');
        _handleUnexpectedDisconnect();
      },
      onDisconnect: (frame) {
        _log.info('Realtime server disconnected (${frame.command})');
      },
      connectionTimeout: const Duration(seconds: 59),
      // 백엔드 setHeartbeatValue(arrayOf(30000L, 40000L)) [server→client, client→server]와 통일.
      // 기존 값은 단위가 microseconds로 잘못 지정되어 있었다(30000µs=30ms).
      heartbeatIncoming: const Duration(milliseconds: 30000), // 서버→클라이언트
      heartbeatOutgoing: const Duration(milliseconds: 40000), // 클라이언트→서버
      stompConnectHeaders: {
        "Qualification": TokenUtils.serviceToken(),
      },
      onConnect: (frame) async {
        _intentionalClose = false;
        _reconnectTimer?.cancel();
        _backOff = 200;
        _log.info('Realtime server connected (restoring ${_subscription.length} subscriptions)');
        for (var sub in _subscription.values) {
          sub.unsubscribeFn = await _subscribe(
            destination: sub.destination,
            callback: sub.callback,
            region: sub.region,
          );
        }
      },
    );
  }
}

class _Subscription {
  String destination;
  BDORegion? region;
  void Function(StompFrame message) callback;
  void Function({Map<String, String>? unsubscribeHeaders})? unsubscribeFn;

  _Subscription({
    required this.destination,
    this.region,
    required this.callback,
    required this.unsubscribeFn,
  });
}
