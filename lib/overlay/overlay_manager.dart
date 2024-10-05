import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverlayManager {
  WindowController? _windowController;

  final StreamController<Map<String, bool>> _overlayStatusController =
      StreamController<Map<String, bool>>.broadcast();

  final Map<String, bool> _overlayStatus = {
    "worldBoss": false,
    "bossHpScaleIndicator": false,
  };

  Stream<Map<String, bool>> get overlayStatus =>
      _overlayStatusController.stream;

  static final _instance = OverlayManager._internal();

  factory OverlayManager() {
    return _instance;
  }

  OverlayManager._internal();

  Future<void> startOverlay() async {
    if (_windowController == null) {
      loadOverlayStatus();
      Display primary = await screenRetriever.getPrimaryDisplay();
      Map<String, dynamic> arguments = {
        'width': primary.size.width,
        'height': primary.size.height,
        'overlay status': _overlayStatus
      };
      _windowController = await DesktopMultiWindow.createWindow(jsonEncode(arguments));
      await _windowController?.setFrame(
          Offset(primary.size.width, primary.size.height) & const Size(0, 0));
      await _windowController?.setTitle("Karanda Overlay");
      await _windowController?.show();
      sendData(method: "callback", data: "initialize");

    }
  }

  Future<void> loadOverlayStatus() async {
    final instance = await SharedPreferences.getInstance();
    Map data = jsonDecode(instance.getString("overlay-status") ?? "");
    for (String key in _overlayStatus.keys) {
      _overlayStatus[key] = data[key] ?? false;
    }
    _overlayStatusController.sink.add(_overlayStatus);
  }

  Future<void> saveOverlayStatus() async {
    final instance = await SharedPreferences.getInstance();
    instance.setString("overlay-status", jsonEncode(_overlayStatus));
  }

  void sendData({required String method, String? data}) {
    if (_windowController != null) {
      DesktopMultiWindow.invokeMethod(
          _windowController!.windowId, method, data);
    }
  }

  void setOverlayStatus({required String key, required bool value}) {
    if (_overlayStatus.containsKey(key)) _overlayStatus[key] = value;
    _overlayStatusController.sink.add(_overlayStatus);
    sendData(method: "overlay status", data: jsonEncode(_overlayStatus));
    saveOverlayStatus();
  }

  void publish() {
    _overlayStatusController.sink.add(_overlayStatus);
  }

  void dispose(){
    _overlayStatusController.close();
  }
}
