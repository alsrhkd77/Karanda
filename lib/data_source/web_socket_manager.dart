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

  /// 클라이언트가 새로 만들어질 때마다 증가한다.
  /// 재연결로 클라이언트가 교체된 뒤에도 낡은 unsubscribeFn을 호출하거나, register 도중
  /// onConnect의 재구독 루프와 경합해 방금 만든 구독을 잘못 덮어쓰는 것을 막는 세대 번호.
  int _generation = 0;

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
      _generation++;
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

  /// 구독 해제. 재연결로 클라이언트가 교체된 뒤의 낡은 해제 함수는 호출하지 않는다.
  ///
  /// 라이브러리(stomp_dart_client)의 해제 함수는 죽은 핸들러에서 `if (!connected) return;`으로
  /// 조용히 빠져나가지만, 그 판정은 낡은 핸들러 기준이라 소켓이 막 끊겼는데 아직 connected가
  /// 남아 있는 찰나에는 StompBadStateException이 날 수 있다. 세대 검사를 1차 방어로,
  /// try/catch를 2차 방어로 둔다.
  void _unsubscribe(_Subscription sub) {
    final fn = sub.unsubscribeFn;
    final generation = sub.generation;
    sub.unsubscribeFn = null;
    sub.generation = -1;
    if (fn == null || generation != _generation) return;
    try {
      fn();
    } catch (e) {
      _log.fine('Failed to unsubscribe ${sub.destination}: $e');
    }
  }

  Future<void> register({
    required String destination,
    BDORegion? region,
    required void Function(StompFrame message) callback,
  }) async {
    // 같은 destination 재등록 시 브로커에 구독이 누적되지 않도록 이전 구독을 먼저 해제한다.
    final previous = _subscription[destination];
    if (previous != null) {
      _unsubscribe(previous);
    }

    // 맵 등록을 await보다 먼저 한다. 구독 요청이 오가는 동안 onConnect의 재구독 루프가 돌아도
    // 이 destination이 누락되지 않게 하기 위함이다.
    final entry = _Subscription(
      destination: destination,
      region: region,
      callback: callback,
      unsubscribeFn: null,
    );
    _subscription[destination] = entry;

    final generation = _generation;
    void Function({Map<String, String>? unsubscribeHeaders})? unsubscribeFn;
    try {
      unsubscribeFn = await _subscribe(
        destination: destination,
        callback: callback,
        region: region,
      );
    } catch (e) {
      // 호출부 다수가 이 결과를 기다리지 않는 fire-and-forget이다. 여기서 삼키지 않으면
      // 미처리 비동기 예외가 되어 운영 로그를 폭주시킨다. 실패해도 다음 onConnect에서 복구된다.
      _log.fine('Failed to subscribe $destination: $e');
    }

    if (unsubscribeFn != null) {
      final stillCurrent =
          generation == _generation && identical(_subscription[destination], entry);
      if (!stillCurrent) {
        // await 사이에 재연결·재등록·해제가 일어났다 — 방금 만든 구독은 더 이상 유효하지 않다.
        if (generation == _generation) {
          try {
            unsubscribeFn();
          } catch (_) {}
        }
      } else if (entry.generation == generation) {
        // onConnect 재구독 루프가 await 사이에 먼저 채웠다면 그쪽이 최신이므로 지금 만든 것을 버린다.
        try {
          unsubscribeFn();
        } catch (_) {}
      } else {
        entry.unsubscribeFn = unsubscribeFn;
        entry.generation = generation;
      }
    }

    _log.info('Subscribe realtime channel: $destination'
        '${region == null ? '' : ' (region: ${region.name})'}');
    if (_subscription.length == 1) {
      activate();
    }
  }

  void unregister({required String destination}) {
    // 맵에서 먼저 제거해, 진행 중일 수 있는 onConnect 재구독 루프가 이 destination을
    // 되살리지 못하게 한다.
    final sub = _subscription.remove(destination);
    if (sub == null) return;
    _unsubscribe(sub);
    _log.info('Unsubscribe realtime channel: $destination');
    if (_subscription.isEmpty) {
      deactivate();
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
        final generation = _generation;
        _log.info('Realtime server connected (restoring ${_subscription.length} subscriptions)');
        // 루프 본문에 await가 있어, 스냅샷 없이 _subscription.values를 그대로 순회하면
        // 그 사이 register/unregister가 맵을 바꿀 때 ConcurrentModificationError가 난다.
        for (final sub in _subscription.values.toList(growable: false)) {
          if (generation != _generation) break; // 순회 도중 재연결로 세대가 바뀜
          if (!identical(_subscription[sub.destination], sub)) continue; // 그 사이 해제·재등록됨
          if (sub.generation == generation) continue; // register()가 이미 이 세대로 구독을 마쳤다

          void Function({Map<String, String>? unsubscribeHeaders})? fn;
          try {
            fn = await _subscribe(
              destination: sub.destination,
              callback: sub.callback,
              region: sub.region,
            );
          } catch (e) {
            _log.fine('Failed to restore ${sub.destination}: $e');
            continue;
          }
          if (fn == null) continue;

          if (generation != _generation || !identical(_subscription[sub.destination], sub)) {
            if (generation == _generation) {
              try {
                fn();
              } catch (_) {}
            }
            continue;
          }
          sub.unsubscribeFn = fn;
          sub.generation = generation;
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

  /// [unsubscribeFn]이 만들어진 클라이언트 세대. -1은 아직 구독 전(또는 해제됨).
  int generation = -1;

  _Subscription({
    required this.destination,
    this.region,
    required this.callback,
    required this.unsubscribeFn,
  });
}
