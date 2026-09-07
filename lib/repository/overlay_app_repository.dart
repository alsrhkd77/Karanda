import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:karanda/data_source/overlay_api.dart';
import 'package:karanda/utils/extension/rect_extension.dart';
import 'package:rxdart/rxdart.dart';

class OverlayAppRepository {
  final OverlayApi _overlayApi;
  final _message = BehaviorSubject<MethodCall>();
  int _parentWindowId = 1;

  OverlayAppRepository({
    required OverlayApi overlayApi,
  })  :_overlayApi = overlayApi {
    DesktopMultiWindow.setMethodHandler(_methodCallHandler);
  }

  Stream<MethodCall> get messageStream => _message.stream;

  Future<void> _methodCallHandler(MethodCall call, int fromWindowId) async {
    _parentWindowId = fromWindowId;
    _message.sink.add(call);
  }

  /// 오버레이 창이 **실제로** 배치된 영역을 메인 앱에 보고한다.
  ///
  /// 오버레이 엔진의 로그는 운영 로그에 저장되지 않으므로(`OperationLogService`는 메인 진입에서만
  /// 초기화된다) 기록은 메인이 담당한다. [corrected]는 창이 한 번 어긋났다가 재배치로 바로잡힌
  /// 경우를 뜻한다.
  Future<void> reportWindowBounds({
    required Rect requested,
    required Rect? actual,
    required bool corrected,
  }) async {
    Map data = {
      "requested": requested.toJson(),
      "actual": actual?.toJson(),
      "corrected": corrected,
    };
    await _overlayApi.sendToOverlay(
      windowController: WindowController.fromWindowId(_parentWindowId),
      method: "window bounds",
      data: jsonEncode(data),
    );
  }

  Future<void> saveRect(String key, Rect rect) async {
    Map data = {
      "feature": key,
      "rect": rect.toJson(),
    };
    await _overlayApi.sendToOverlay(
      windowController: WindowController.fromWindowId(_parentWindowId),
      method: "position",
      data: jsonEncode(data),
    );

  }
}
