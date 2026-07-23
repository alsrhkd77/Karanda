import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:karanda/data_source/overlay_api.dart';
import 'package:karanda/data_source/overlay_settings_data_source.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/model/mirroring_settings.dart';
import 'package:karanda/model/monitor_device.dart';
import 'package:karanda/model/overlay_settings.dart';
import 'package:karanda/model/window_info.dart';
import 'package:karanda/utils/overlay_window_utils/overlay_window_utils.dart';
import 'package:karanda/utils/window_mirror/window_mirror.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

/// 오버레이 기능 운영 로그.
final _log = Logger('overlay');

class OverlayRepository {
  final OverlaySettingsDataSource _overlaySettingsDataSource;
  final OverlayApi _overlayApi;
  final Completer<WindowController> _completer = Completer();
  final _settings = BehaviorSubject<OverlaySettings>();

  /// 미러링 소스 창 (세션 한정 — 앱 재시작 시 다시 선택, 영속화하지 않음)
  final _mirroringSource = BehaviorSubject<WindowInfo?>.seeded(null);

  OverlayRepository(
      {required OverlaySettingsDataSource overlaySettingsDataSource,
      required OverlayApi overlayApi})
      : _overlaySettingsDataSource = overlaySettingsDataSource,
        _overlayApi = overlayApi {
    _settings.stream.listen(saveSettings);
    DesktopMultiWindow.setMethodHandler(_methodCallHandler);
  }

  Future<WindowController> get _windowController => _completer.future;

  Stream<OverlaySettings> get settingsStream => _settings.stream;

  Stream<WindowInfo?> get mirroringSourceStream => _mirroringSource.stream;

  Future<void> _methodCallHandler(MethodCall call, int fromWindowId) async {
    switch (call.method) {
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

  Future<void> startOverlay(MonitorDevice monitorDevice) async {
    if (kIsWeb || !Platform.isWindows) return;
    final windowController = await _overlayApi.startOverlay();
    await Future.delayed(const Duration(seconds: 1));
    _overlayApi.sendToOverlay(
      windowController: windowController,
      method: "set window",
      data: jsonEncode(monitorDevice.toJson()),
    );
    await Future.delayed(const Duration(seconds: 1));
    _completer.complete(windowController);
  }

  /// 앱 종료·업데이트 시 오버레이 자식 창(별도 엔진)을 정리한다.
  /// 오버레이 엔진은 메인과 **같은 프로세스**에 있으므로, 메인 창만 destroy하면 프로세스가
  /// 살아남아 업데이트 인스톨러가 실행 파일을 교체하지 못한다. 실제 프로세스 완전 종료는
  /// 호출측(예: `InitializerService.update`)이 `exit`로 보장한다.
  Future<void> teardown() async {
    if (kIsWeb || !Platform.isWindows) return;
    try {
      final subWindowIds = await DesktopMultiWindow.getAllSubWindowIds();
      for (final windowId in subWindowIds) {
        await WindowController.fromWindowId(windowId).close();
      }
      _log.info('Overlay torn down for shutdown');
    } catch (e, s) {
      _log.warning('Overlay teardown failed', e, s);
    }
  }

  Future<void> sendToOverlay({required String method, String data = ""}) async {
    if (kIsWeb || !Platform.isWindows) return;
    final windowController =
        await _windowController.timeout(const Duration(seconds: 30));
    _overlayApi.sendToOverlay(
      windowController: windowController,
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

  /// 초기화 마지막 단계에서 호출. 오버레이 창이 켜지고 안정화된 뒤 저장된 설정값(활성 기능·위치·
  /// 투명도 등)을 한 번 보내 위젯을 활성 상태로 전환한다. 오버레이가 시작되지 않았으면(창 컨트롤러
  /// 미완료) `sendToOverlay`의 30초 대기에 걸리지 않도록 조용히 건너뛴다.
  Future<void> sendInitialSettings() async {
    if (kIsWeb || !Platform.isWindows) return;
    if (!_completer.isCompleted) return;
    final value = _settings.valueOrNull;
    if (value == null) return;
    await sendOverlaySettings(value);
  }

  void activate(OverlayFeatures value) {
    _log.info('Overlay enabled: ${value.name}');
    final snapshot = _settings.value..activatedFeatures.add(value);
    sendOverlaySettings(snapshot);
    _settings.sink.add(snapshot);
  }

  void deactivate(OverlayFeatures value) {
    _log.info('Overlay disabled: ${value.name}');
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

  /// 미러링 가능한 창 목록 조회
  List<WindowInfo> getMirrorableWindows() {
    if (kIsWeb || !Platform.isWindows) return [];
    return WindowMirrorUtils().getMirrorableWindows();
  }

  /// 미러링 소스 선택·해제. 영속 설정을 건드리지 않고 오버레이 엔진에만 전송한다.
  Future<void> setMirroringSource(WindowInfo? value) async {
    if (kIsWeb || !Platform.isWindows) return;
    _mirroringSource.sink.add(value);
    _log.info(value == null
        ? 'Mirroring source cleared'
        : 'Mirroring source selected');
    await sendToOverlay(
      method: OverlayFeatures.mirroring.name,
      data: jsonEncode({"sourceHandle": value?.handle ?? 0}),
    );
  }

  /// 미러링 설정(크롭·박스 크기) 변경. 저장 및 오버레이 전송.
  void updateMirroringSettings(MirroringSettings value) {
    final snapshot = _settings.value..mirroringSettings = value;
    sendOverlaySettings(snapshot);
    _settings.sink.add(snapshot);
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
    _log.info('Overlay initialized (displays: ${display.length}, '
        'monitor: ${settings.monitorDevice.rect.width.toInt()}x${settings.monitorDevice.rect.height.toInt()})');
    _settings.sink.add(settings);
    return settings;
  }

  Future<void> saveSettings(OverlaySettings value) async {
    //await sendActivationStatus(value.activationStatus);
    await _overlaySettingsDataSource.saveSettings(value);
  }
}
