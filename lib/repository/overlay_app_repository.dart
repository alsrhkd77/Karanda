import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:karanda/data_source/overlay_app_data_source.dart';
import 'package:rxdart/rxdart.dart';

class OverlayAppRepository {
  final OverlayAppDataSource _appDataSource;
  final _message = BehaviorSubject<MethodCall>();

  OverlayAppRepository({
    required OverlayAppDataSource appDataSource
  }) : _appDataSource = appDataSource {
    DesktopMultiWindow.setMethodHandler(_methodCallHandler);
  }

  Stream<MethodCall> get messageStream => _message.stream;

  Future<void> _methodCallHandler(MethodCall call, int fromWindowId) async {
    _message.sink.add(call);
  }

  Future<void> saveRect(String key, Rect rect) async {
    return await _appDataSource.saveRect(key, rect);
  }

  Future<Rect?> loadRect(String key) async {
    return await _appDataSource.loadRect(key);
  }
}
