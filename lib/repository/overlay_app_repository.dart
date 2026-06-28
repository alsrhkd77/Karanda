import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:karanda/data_source/overlay_api.dart';
import 'package:karanda/utils/extension/rect_extension.dart';
import 'package:rxdart/rxdart.dart';

class OverlayAppRepository {
  final OverlayApi _overlayApi;
  final _message = BehaviorSubject<MethodCall>();

  OverlayAppRepository({
    required OverlayApi overlayApi,
  }) : _overlayApi = overlayApi {
    _init();
  }

  Future<void> _init() async {
    // 먼저 이 엔진의 채널 핸들러를 등록한 뒤 준비 완료를 알린다. 그래야
    // 양방향 페어가 형성된 후 메인 창이 모니터/설정을 전송한다.
    await _overlayApi.setMethodHandler(_methodCallHandler);
    await _notifyReady();
  }

  /// 메인 창에 "ready"를 전송한다. 양방향 채널 페어가 형성될 때까지 재시도한다
  /// (메인 쪽이 아직 핸들러를 등록 중일 수 있다).
  Future<void> _notifyReady() async {
    for (int attempt = 0; attempt < 25; attempt++) {
      try {
        await _overlayApi.sendToOverlay(method: "ready");
        developer.log('Sent ready to main window', name: 'overlay');
        return;
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
    developer.log('Failed to deliver ready handshake to main window',
        name: 'overlay');
  }

  Stream<MethodCall> get messageStream => _message.stream;

  Future<void> _methodCallHandler(MethodCall call) async {
    _message.sink.add(call);
  }

  /// 오버레이 창에 스타일(투명/클릭스루/위치) 적용이 끝났음을 메인에 알린다.
  /// 메인은 이 신호를 받고 plugin show()로 창을 표시한다.
  Future<void> notifyStyled() async {
    await _overlayApi.sendToOverlay(method: "styled");
  }

  Future<void> saveRect(String key, Rect rect) async {
    Map data = {
      "feature": key,
      "rect": rect.toJson(),
    };
    await _overlayApi.sendToOverlay(
      method: "position",
      data: jsonEncode(data),
    );
  }
}
