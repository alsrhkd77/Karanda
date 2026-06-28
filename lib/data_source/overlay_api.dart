import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:screen_retriever/screen_retriever.dart';

class OverlayApi {
  /// 메인 창과 오버레이 서브윈도우가 공유하는 양방향(bidirectional) 채널.
  /// desktop_multi_window 0.3에서는 두 엔진이 페어를 이뤄 서로를 직접 호출하므로
  /// 메시지 전송에 windowId가 필요하지 않다.
  static const _channel = WindowMethodChannel(
    'karanda_overlay',
    mode: ChannelMode.bidirectional,
  );

  Future<WindowController> startOverlay() async {
    Display primary = await screenRetriever.getPrimaryDisplay();
    Map<String, dynamic> arguments = {
      'width': primary.size.width,
      'height': primary.size.height,
    };
    // 창을 숨긴 채로 생성한다. 여기서 show()를 호출하면 스타일(전체화면/투명/
    // 클릭스루) 적용 전에 기본 크기의 검은 창이 잠깐 노출된다. 창은 오버레이가
    // "set window"를 받아 setOverlay를 적용할 때 함께 표시된다(SWP_SHOWWINDOW).
    final windowController = await WindowController.create(
      WindowConfiguration(
        arguments: jsonEncode(arguments),
        hiddenAtLaunch: true,
      ),
    );
    return windowController;
  }

  /// 오버레이 창을 플러그인 레벨에서 표시한다. 이 호출이 있어야 Flutter
  /// 임베더가 서브윈도우의 프레임을 그리기 시작한다.
  Future<void> showOverlay(WindowController windowController) {
    return windowController.show();
  }

  Future<void> sendToOverlay({
    required String method,
    String data = "",
  }) async {
    await _channel.invokeMethod(method, data);
  }

  Future<void> setMethodHandler(
      Future<dynamic> Function(MethodCall call) handler) {
    return _channel.setMethodCallHandler(handler);
  }
}
