import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:karanda/common/custom_web_socket_channel/web_visibility/web_visibility.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

/// Windows용 [pingInterval]이 설정되어있고,
/// Web용 백그라운드 감지가 적용되어
/// 자동으로 reconnect를 실행하는 커스텀 웹소켓
class CustomWebSocketChannel {
  final StreamController _controller = StreamController.broadcast();
  WebSocketChannel? _webSocketChannel;
  final WebVisibility _webVisibility = WebVisibility();
  late final Uri _targetUri;
  bool _connected = false;
  Timer? _visibilityTimer;
  Timer? _reconnectTimer;
  int _reconnectLatency = 10;

  Stream get stream => _controller.stream;

  bool get connected => _connected;

  CustomWebSocketChannel(String url) {
    _targetUri = Uri.parse(url);
    if (kIsWeb) {
      _addWebVisibilityListener();
    }
  }

  Future<void> connect() async {
    if (connected) return;
    try {
      if (kIsWeb) {
        _webSocketChannel = WebSocketChannel.connect(_targetUri);
      } else {
        _webSocketChannel = IOWebSocketChannel.connect(
          _targetUri,
          pingInterval: const Duration(seconds: 40),
        );
      }
      await _webSocketChannel!.ready.timeout(const Duration(seconds: 30));
      _webSocketChannel?.stream.listen((event) {
        _controller.sink.add(event);
      }, onDone: () {
        _connected = false;
        if (_webSocketChannel?.closeCode == status.noStatusReceived) {
          connect();
        } else if (_webSocketChannel?.closeCode != status.normalClosure) {
          _reconnect();
        }
      }, onError: (object, stacktrace) {
        _connected = false;
        print(
            'error code:${_webSocketChannel?.closeCode}, reason:${_webSocketChannel?.closeReason}\n$stacktrace');
        _reconnect();
      });
      _connected = true;
      _resetReconnectLatency();
    } on TimeoutException {
      _reconnect();
    } on SocketException {
      _reconnect();
    }
  }

  void send(var message){
    if(connected){
      _webSocketChannel?.sink.add(message);
    }
  }

  void disconnect() {
    _webSocketChannel?.sink.close(status.normalClosure);
    _webSocketChannel = null;
    _resetReconnectLatency();
    _connected = false;
  }

  void close() {
    disconnect();
    _controller.sink.close();
  }

  void _addWebVisibilityListener() {
    _webVisibility.stream.listen((visible) {
      if (visible) {
        if (_visibilityTimer != null && _visibilityTimer!.isActive) {
          _visibilityTimer?.cancel();
          _visibilityTimer = null;
        }
        if(!_connected){
          connect();
        }
      } else {
        _visibilityTimer = Timer(const Duration(seconds: 30), () {
          disconnect();
        });
      }
    });
  }

  void _reconnect() {
    _increaseReconnectLatency();
    _reconnectTimer = Timer(Duration(seconds: _reconnectLatency), () {
      connect();
    });
  }

  void _resetReconnectLatency() {
    _reconnectLatency = 10;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _increaseReconnectLatency() {
    _reconnectLatency = _reconnectLatency * 3;
    if (_reconnectLatency > 300) {
      _reconnectLatency = 300;
    }
  }
}
