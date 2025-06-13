import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';
import 'package:karanda/utils/token_utils.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dart:developer' as developer;

import '../utils/web_visibility/web_visibility.dart';

class WebSocketManager {
  final WebVisibility _webVisibility = WebVisibility();
  final String _prefix = "/live-data";
  StompClient? _client;
  Timer? _reconnectTimer;
  int _backOff = 200;
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
    if (_client == null || !_client!.connected) {
      _client = StompClient(config: _buildConfig());
      _client!.activate();
    }
  }

  void deactivate() {
    if (_client != null && _client!.connected) {
      _client?.deactivate();
      _client = null;
    }
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
      onWebSocketDone: () {
        _reconnectTimer?.cancel();
        _backOff = min(_backOff * 2, 600000);
        _reconnectTimer = Timer(Duration(milliseconds: _backOff), activate);
        _client?.deactivate();
        _client = null;
      },
      onDisconnect: (frame) {
        developer.log("STOMP disconnected, ${frame.command}");
      },
      connectionTimeout: const Duration(seconds: 59),
      heartbeatIncoming: const Duration(microseconds: 30000),
      heartbeatOutgoing: const Duration(microseconds: 40000),
      stompConnectHeaders: {
        "Qualification": TokenUtils.serviceToken(),
      },
      onConnect: (frame) async {
        _reconnectTimer?.cancel();
        _backOff = 200;
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
