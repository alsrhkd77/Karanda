import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:karanda/overlay/utils/overlay_utils.dart' as util;

class OverlayDataController {
  Size _screenSize = Size.zero;
  final Map<String, void Function()> _callback = {};

  final StreamController<Map> _overlayStatusController = StreamController<Map>();
  final StreamController<bool> _editModeController = StreamController<bool>();
  final StreamController<Map> _nextWorldBossDataController = StreamController<Map>();

  Stream<bool> get editModeStream => _editModeController.stream;
  Stream<Map> get nextBossStream => _nextWorldBossDataController.stream;
  Stream<Map> get overlayStatusStream => _overlayStatusController.stream;

  Size get screenSize => _screenSize;

  static final OverlayDataController _instance =
      OverlayDataController._internal();

  factory OverlayDataController() {
    return _instance;
  }

  OverlayDataController._internal() {
    registerCallback(
        method: "initialize",
        callback: () {
          util.setOverlayMode(width: _screenSize.width, height: _screenSize.height);
          _editModeController.sink.add(false);
        });
    registerCallback(
        method: "enable edit mode",
        callback: () {
          util.enableEditMode();
          _editModeController.sink.add(true);
        });
    DesktopMultiWindow.setMethodHandler(_methodCallHandler);
  }

  void registerCallback(
      {required String method, required void Function() callback}) {
    _callback[method] = callback;
  }

  Future<void> _methodCallHandler(MethodCall call, int fromWindowId) async {
    switch (call.method) {
      case "callback":
        if (_callback.containsKey(call.arguments)) {
          _callback[call.arguments]!();
        }
        break;
      case "overlay status":
        _overlayStatusController.sink.add(jsonDecode(call.arguments));
        break;
      case "next world boss":
        _nextWorldBossDataController.sink.add(jsonDecode(call.arguments));
        break;
      default:
        developer.log(
          'Unsupported method ${call.method}',
          name: 'Karanda Overlay',
        );
        break;
    }
  }

  void setScreenSize({required double width, required double height}) {
    _screenSize = Size(width, height);
  }

  void setOverlayStatus(Map data){
    _overlayStatusController.sink.add(data);
  }

  void disableEditMode(){
    util.disableEditMode();
    _editModeController.sink.add(false);
  }
}
