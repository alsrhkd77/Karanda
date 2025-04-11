import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/token_factory.dart';
import 'package:karanda/common/web_visibility/web_visibility.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dart:developer' as developer;

class WebSocketManager {
  final WebVisibility _webVisibility = WebVisibility();
  StompClient? _client;
  Timer? _reconnectTimer;
  int _backOff = 200;
  final Map<String, _Subscription> _subscription = {};

  static final WebSocketManager _instance = WebSocketManager._internal();

  factory WebSocketManager() {
    return _instance;
  }

  WebSocketManager._internal() {
    activate();
    if (kIsWeb) {
      _webVisibility.stream.listen((visible) {
        if (visible) {
          activate();
        } else {
          deactivate();
        }
      });
    }
  }

  void activate() {
    if (_client == null || !_client!.connected) {
      _client = StompClient(config: _buildConfig());
      _client!.activate();
    }
  }

  void deactivate() {
    if (_client != null && _client!.connected) {
      _client!.deactivate();
    }
  }

  Future<void> register(
      {required String destination,
      required void Function(StompFrame message) callback}) async {
    var unsubscribeFn = _client != null && _client!.isActive
        ? await _subscribe(destination: destination, callback: callback)
        : null;
    _subscription[destination] = _Subscription(
      destination: destination,
      callback: callback,
      unsubscribeFn: unsubscribeFn,
    );
  }

  void unregister({required String destination}) {
    if (_subscription.containsKey(destination)) {
      if (_subscription[destination]!.unsubscribeFn != null) {
        _subscription[destination]!.unsubscribeFn!();
      }
      _subscription.remove(destination);
    }
  }

  Future<void Function({Map<String, String>? unsubscribeHeaders})?> _subscribe(
      {required String destination,
      required void Function(StompFrame message) callback}) async {
    Map<String, String> headers = {};
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'karanda-token');
    if (token != null) {
      headers.addAll({'Authorization': token});
    }
    headers.addAll({'Qualification': TokenFactory.serviceToken()});
    destination = destination.replaceFirst('/REGION/', '/KR/');
    return _client?.subscribe(
      destination: destination,
      headers: headers,
      callback: callback,
    );
  }

  StompConfig _buildConfig() {
    return StompConfig(
      url: Api.webSocketChannel,
      onWebSocketDone: (){
        _reconnectTimer?.cancel();
        _backOff = min(_backOff * 2, 600000);
        _reconnectTimer = Timer(Duration(milliseconds: _backOff), activate);
        _client?.deactivate();
        _client = null;
      },
      onDisconnect: (frame){
        developer.log("STOMP disconnected, ${frame.command}");
      },
      connectionTimeout: const Duration(seconds: 59),
      heartbeatIncoming: const Duration(microseconds: 30000),
      heartbeatOutgoing: const Duration(microseconds: 40000),
      stompConnectHeaders: {
        "Qualification": TokenFactory.serviceToken(),
      },
      onConnect: (frame) async {
        _reconnectTimer?.cancel();
        _backOff = 200;
        for (var sub in _subscription.values) {
          sub.unsubscribeFn = await _subscribe(
            destination: sub.destination,
            callback: sub.callback,
          );
        }
      },
    );
  }
}

class _Subscription {
  String destination;
  void Function(StompFrame message) callback;
  void Function({Map<String, String>? unsubscribeHeaders})? unsubscribeFn;

  _Subscription({
    required this.destination,
    required this.callback,
    required this.unsubscribeFn,
  });
}
