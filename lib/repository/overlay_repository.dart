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
        final snapshot = _settings.value..position[key] = _rectFromJson(data["rect"]);
        _settings.sink.add(snapshot);
        break;
      case ("window bounds"):
        _logWindowBounds(jsonDecode(call.arguments));
        break;
      default:
    }
    //_message.sink.add(call);
  }

  Rect _rectFromJson(Map json) {
    return Rect.fromLTWH(
      (json["left"] as num).toDouble(),
      (json["top"] as num).toDouble(),
      (json["width"] as num).toDouble(),
      (json["height"] as num).toDouble(),
    );
  }

  String _describe(Rect rect) {
    return '${rect.width.toInt()}x${rect.height.toInt()} '
        'at ${rect.left.toInt()},${rect.top.toInt()}';
  }

  /// 오버레이 창이 **실제로** 배치된 영역 보고(오버레이 엔진 → 메인).
  ///
  /// 오버레이 엔진의 로그는 운영 로그로 저장되지 않으므로(초기화가 메인 진입에서만 일어난다)
  /// 메인에서 기록한다. 요청값만 남기면 이번처럼 "요청은 맞았는데 창이 작다"를 구분할 수 없다.
  void _logWindowBounds(Map data) {
    final requested = _rectFromJson(data["requested"]);
    final actual =
        data["actual"] == null ? null : _rectFromJson(data["actual"]);
    if (actual == null) {
      _log.warning(
          'Overlay window bounds unavailable (requested ${_describe(requested)})');
      return;
    }
    if (actual.width.round() != requested.width.round() ||
        actual.height.round() != requested.height.round() ||
        actual.left.round() != requested.left.round() ||
        actual.top.round() != requested.top.round()) {
      _log.warning('Overlay window bounds mismatch '
          '(requested ${_describe(requested)}, actual ${_describe(actual)})');
      return;
    }
    /* corrected: 창이 한 번 어긋났다가(모니터 간 DPI 전환 등) 재배치로 바로잡힌 경우 */
    _log.info(data["corrected"] == true
        ? 'Overlay window placed after correction (${_describe(actual)})'
        : 'Overlay window placed (${_describe(actual)})');
  }

  Future<void> startOverlay(MonitorDevice monitorDevice) async {
    if (kIsWeb || !Platform.isWindows) return;
    try {
      final windowController = await _overlayApi.startOverlay(monitorDevice);
      await Future.delayed(const Duration(seconds: 1));
      _overlayApi.sendToOverlay(
        windowController: windowController,
        method: "set window",
        data: jsonEncode(monitorDevice.toJson()),
      );
      await Future.delayed(const Duration(seconds: 1));
      _completer.complete(windowController);
    } catch (e, s) {
      // _completer를 미완료로 남기면 이후 모든 sendToOverlay 호출이 30초 타임아웃을
      // 반복하며 리스너를 누적시킨다. 실패로 완료해 즉시 실패하도록 만든다.
      if (!_completer.isCompleted) {
        _completer.completeError(e, s);
      }
      rethrow;
    }
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

  /// 오버레이가 시작되지 않았거나 시작에 실패했으면 조용히 포기한다.
  ///
  /// 호출부 다수(월드보스 스케줄 갱신, 알림 발생 등)가 결과를 기다리지 않는
  /// fire-and-forget 호출이다. 여기서 삼키지 않으면 미처리 비동기 예외로 번져 운영
  /// 로그를 폭주시킨다. 실패는 고빈도로 반복될 수 있어 fine으로만 남긴다.
  Future<void> sendToOverlay({required String method, String data = ""}) async {
    if (kIsWeb || !Platform.isWindows) return;
    try {
      final windowController =
          await _windowController.timeout(const Duration(seconds: 30));
      _overlayApi.sendToOverlay(
        windowController: windowController,
        method: method,
        data: data,
      );
    } catch (e) {
      _log.fine('Overlay is not available for $method: $e');
    }
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
    final devices = await OverlayWindowUtils().getAllMonitorDevices();
    settings.monitorDevice =
        await _resolveMonitor(settings.monitorDevice, devices);
    _log.info('Overlay initialized (displays: ${devices.length})');
    _settings.sink.add(settings);
    return settings;
  }

  /// 저장된 모니터를 현재 연결된 모니터 목록으로 **재해석**한다.
  ///
  /// 저장된 rect는 신뢰하지 않는다 — 구버전은 논리 픽셀로 저장했고, 해상도·배율 변경으로도
  /// 값이 바뀐다. 식별자로 같은 모니터를 찾아 rect를 최신 값으로 바꿔주므로 별도 마이그레이션이
  /// 필요 없고, 배율만 바꾼 사용자가 주 모니터로 되돌아가지도 않는다.
  Future<MonitorDevice> _resolveMonitor(
    MonitorDevice saved,
    List<MonitorDevice> devices,
  ) async {
    for (final device in devices) {
      if (device == saved) return device;
    }
    /* 모니터 배치 순서가 바뀌면 name(\\.\DISPLAYn)이 달라진다. deviceID로 유일하게 특정될
       때만 채택하고, 같은 식별자가 여럿이면 엉뚱한 모니터를 고르느니 주 모니터로 간다. */
    final sameId =
        devices.where((device) => device.deviceID == saved.deviceID).toList();
    if (sameId.length == 1 && sameId.first.deviceID.isNotEmpty) {
      return sameId.first;
    }
    _log.info('Saved overlay display not found; using primary display');
    return await OverlayWindowUtils().getPrimaryMonitorDevice();
  }

  Future<void> saveSettings(OverlaySettings value) async {
    //await sendActivationStatus(value.activationStatus);
    await _overlaySettingsDataSource.saveSettings(value);
  }
}
