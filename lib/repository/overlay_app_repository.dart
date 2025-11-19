import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:karanda/data_source/overlay_api.dart';
import 'package:karanda/data_source/overlay_app_data_source.dart';
import 'package:rxdart/rxdart.dart';

class OverlayAppRepository {
  final OverlayAppDataSource _appDataSource;
  final OverlayApi _overlayApi;
  final _message = BehaviorSubject<MethodCall>();
  int _parentWindowId = 1;

  OverlayAppRepository({
    required OverlayAppDataSource appDataSource,
    required OverlayApi overlayApi,
  })  : _appDataSource = appDataSource,
        _overlayApi = overlayApi {
    DesktopMultiWindow.setMethodHandler(_methodCallHandler);
  }

  Stream<MethodCall> get messageStream => _message.stream;

  Future<void> _methodCallHandler(MethodCall call, int fromWindowId) async {
    _parentWindowId = fromWindowId;
    _message.sink.add(call);
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

    //return await _appDataSource.saveRect(key, rect);
  }

  Future<Rect?> loadRect(String key) async {
    return await _appDataSource.loadRect(key);
  }
}
