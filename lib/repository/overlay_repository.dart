import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:karanda/data_source/overlay_api.dart';
import 'package:karanda/data_source/overlay_settings_data_source.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/model/monitor_device.dart';
import 'package:karanda/model/overlay_settings.dart';
import 'package:karanda/utils/overlay_window_utils/overlay_window_utils.dart';
import 'package:rxdart/rxdart.dart';

class OverlayRepository {
  final OverlaySettingsDataSource _overlaySettingsDataSource;
  final OverlayApi _overlayApi;
  final Completer<WindowController> _completer = Completer();
  final _settings = BehaviorSubject<OverlaySettings>();

  /// 오버레이가 차지할 모니터. 오버레이가 준비 완료("ready" 핸드셰이크)를 알리면
  /// 해당 창으로 전송된다.
  MonitorDevice? _pendingMonitorDevice;

  OverlayRepository(
      {required OverlaySettingsDataSource overlaySettingsDataSource,
      required OverlayApi overlayApi})
      : _overlaySettingsDataSource = overlaySettingsDataSource,
        _overlayApi = overlayApi {
    _settings.stream.listen(saveSettings);
    _overlayApi.setMethodHandler(_methodCallHandler);
  }

  Future<WindowController> get _windowController => _completer.future;

  Stream<OverlaySettings> get settingsStream => _settings.stream;

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case ("ready"):
        // 오버레이 창이 메시지 핸들러 등록을 마치고 메시지를 받을 준비가 됐다.
        // 이 시점에 대상 모니터와 현재 설정을 전송한다. 이보다 먼저 보내면
        // 오버레이의 채널 등록과 경합이 발생해 메시지가 조용히 유실된다.
        // 아직 창은 표시하지 않는다. 오버레이가 스타일을 적용한 뒤 "styled"를
        // 보내면 그때 표시한다(검은 창 노출 방지).
        developer.log('Overlay reported ready', name: 'overlay');
        final monitorDevice = _pendingMonitorDevice;
        if (monitorDevice != null) {
          _overlayApi.sendToOverlay(
            method: "set window",
            data: jsonEncode(monitorDevice.toJson()),
          );
        }
        final settings = _settings.valueOrNull;
        if (settings != null) {
          _overlayApi.sendToOverlay(
            method: "settings",
            data: jsonEncode(settings),
          );
        }
        break;
      case ("styled"):
        // 오버레이가 자기 창에 투명/클릭스루/위치 스타일을 모두 적용했다.
        // 이제 plugin show()로 창을 표시하면 이미 투명한 상태에서 위젯이
        // 렌더링되어 검은 창이 보이지 않는다.
        developer.log('Overlay reported styled; showing window',
            name: 'overlay');
        final controller = _overlayController;
        if (controller != null) {
          await _overlayApi.showOverlay(controller);
          // 표시 후 레이어드(클릭스루)를 적용하도록 오버레이에 알린다.
          _overlayApi.sendToOverlay(method: "finalize");
          if (!_completer.isCompleted) {
            _completer.complete(controller);
          }
        }
        break;
      case ("position"):
        final data = jsonDecode(call.arguments);
        final key = OverlayFeatures.values.byName(data["feature"]);
        final rect = Rect.fromLTWH(
          data["rect"]["left"],
          data["rect"]["top"],
          data["rect"]["width"],
          data["rect"]["height"],
        );
        final snapshot = _settings.value..position[key] = rect;
        _settings.sink.add(snapshot);
        break;
      default:
    }
    //_message.sink.add(call);
  }

  WindowController? _overlayController;

  Future<void> startOverlay(MonitorDevice monitorDevice) async {
    if (kIsWeb || !Platform.isWindows) return;
    _pendingMonitorDevice = monitorDevice;
    // 창을 숨김 상태로 생성만 한다. 표시는 오버레이가 스타일을 적용한 뒤
    // 보내는 "styled" 신호를 받아 plugin show()로 수행한다(검은 창 노출 방지).
    // win32 DWM 호출을 메인 엔진에서 하면 실패해 크래시가 나므로 스타일 적용은
    // 창을 소유한 오버레이 엔진이 담당한다.
    _overlayController = await _overlayApi.startOverlay();
  }

  Future<void> sendToOverlay({required String method, String data = ""}) async {
    if (kIsWeb || !Platform.isWindows) return;
    // 전송 전에 오버레이 창이 생성될 때까지 기다린다.
    await _windowController.timeout(const Duration(seconds: 30));
    _overlayApi.sendToOverlay(
      method: method,
      data: data,
    );
  }

  Future<void> switchEditMode() async {
    await sendToOverlay(method: "edit mode");
  }

  Future<void> sendOverlaySettings(OverlaySettings value) async {
    await sendToOverlay(method: "settings", data: jsonEncode(value));
  }

  void activate(OverlayFeatures value) {
    final snapshot = _settings.value..activatedFeatures.add(value);
    sendOverlaySettings(snapshot);
    _settings.sink.add(snapshot);
  }

  void deactivate(OverlayFeatures value) {
    final snapshot = _settings.value..activatedFeatures.remove(value);
    sendOverlaySettings(snapshot);
    _settings.sink.add(snapshot);
  }

  void changeMonitor(MonitorDevice value) {
    final snapshot = _settings.value..monitorDevice = value;
    sendToOverlay(
      method: "set window",
      data: jsonEncode(snapshot.monitorDevice.toJson()),
    );
    _settings.sink.add(snapshot);
  }

  Future<List<MonitorDevice>> getMonitorList() async {
    return await OverlayWindowUtils().getAllMonitorDevices();
  }

  void resetWidgets() {
    sendToOverlay(method: "reset widgets");
  }

  void setOpacity(OverlayFeatures key, int value) {
    final snapshot = _settings.value..opacity[key] = value;
    sendOverlaySettings(snapshot);
    _settings.sink.add(snapshot);
  }

  void showWorldBossName(bool value) {
    final snapshot = _settings.value..showWorldBossName = value;
    sendOverlaySettings(snapshot);
    _settings.sink.add(snapshot);
  }

  Future<OverlaySettings> loadSettings() async {
    final settings = await _overlaySettingsDataSource.loadSettings();
    final display = await OverlayWindowUtils().getAllMonitorDevices();
    if (display.where((device) => device == settings.monitorDevice).isEmpty) {
      settings.monitorDevice =
          await OverlayWindowUtils().getPrimaryMonitorDevice();
    }
    _settings.sink.add(settings);
    return settings;
  }

  Future<void> saveSettings(OverlaySettings value) async {
    //await sendActivationStatus(value.activationStatus);
    await _overlaySettingsDataSource.saveSettings(value);
  }
}
