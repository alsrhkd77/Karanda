import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:karanda/data_source/overlay_app_data_source.dart';
import 'package:rxdart/rxdart.dart';

class OverlayAppRepository {
  final OverlayAppDataSource _appDataSource;
  final _message = BehaviorSubject<MethodCall>();
  final _screenSize = BehaviorSubject<Size>();

  OverlayAppRepository({
    required OverlayAppDataSource appDataSource,
    required Size screenSize,
  }) : _appDataSource = appDataSource {
    DesktopMultiWindow.setMethodHandler(_methodCallHandler);
    _screenSize.sink.add(screenSize);
  }

  Stream<MethodCall> get messageStream => _message.stream;

  Size get screenSize => _screenSize.value;

  Future<void> _methodCallHandler(MethodCall call, int fromWindowId) async {
    print("${call.method} : ${call.arguments}");
    _message.sink.add(call);
  }

  Future<void> saveRect(String key, Rect rect) async {
    return await _appDataSource.saveRect(key, rect);
  }

  Future<Rect?> loadRect(String key) async {
    return await _appDataSource.loadRect(key);
  }
}
