import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/model/app_notification_message.dart';
import 'package:karanda/model/monitor_device.dart';
import 'package:karanda/model/overlay_settings.dart';
import 'package:karanda/repository/overlay_app_repository.dart';
import 'package:karanda/ui/core/theme/app_theme.dart';
import 'package:karanda/ui/core/theme/dimens.dart';
import 'package:karanda/ui/core/ui/snack_bar_content.dart';
import 'package:karanda/utils/overlay_window_utils/overlay_window_utils.dart';
import 'package:logging/logging.dart';

import 'package:rxdart/rxdart.dart';

/// 오버레이 엔진 로그. 이 엔진의 로그는 운영 로그로 저장되지 않으므로(초기화가 메인 진입
/// 전용) 사용자에게 보여야 할 내용은 메인으로 보고해 기록한다.
final _log = Logger('overlay app');

class OverlayAppService {
  /// 콜백이 아직 등록되지 않은 메시지를 담아두는 버퍼의 상한.
  /// 정상 경로에서는 알려진 메서드만 오가므로 여기 걸릴 일이 없지만, 방어적으로 둔다.
  static const int _maxUnhandledMessages = 32;

  final OverlayAppRepository _appRepository;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;
  final Map<String, void Function(MethodCall)> _callbacks = {};
  final List<MethodCall> _unhandledMessages = [];
  final _editMode = BehaviorSubject<bool>.seeded(false);
  final _loading = BehaviorSubject<bool>.seeded(true);
  final _resetWidgets = StreamController<bool>.broadcast();
  final _settings = BehaviorSubject<OverlaySettings>();

  OverlayAppService({
    required OverlayAppRepository appRepository,
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  })  : _appRepository = appRepository,
        _scaffoldMessengerKey = scaffoldMessengerKey {
    _appRepository.messageStream.listen(_messageHandler);
    _registerCallbacks();
  }

  Stream<bool> get editModeStream => _editMode.stream;

  Stream<bool> get loadingStream => _loading.stream;

  Stream<bool> get resetWidgetsStream => _resetWidgets.stream;

  Stream<OverlaySettings> get settingsStream => _settings.stream;

  Stream<Map<OverlayFeatures, bool>> get activationStatusStream =>
      settingsStream.map((value) => value.activationStatus);

  Stream<Map<OverlayFeatures, Rect>> get positionStream =>
      settingsStream.map((value) => value.position);

  Stream<Map<OverlayFeatures, int>> get opacityStream =>
      settingsStream.map((value) => value.opacity);

  void registerCallback({
    required String key,
    required void Function(MethodCall) callback,
  }) {
    _callbacks[key] = callback;
    // 재생 후 버퍼에서 제거한다. 그렇지 않으면 같은 메시지가 계속 남아 있다가 이 키가
    // 나중에(예: 오버레이 위젯 재마운트) 다시 등록될 때마다 중복 재생된다.
    final unhandled = _unhandledMessages.where((msg) => msg.method == key).toList();
    _unhandledMessages.removeWhere((msg) => msg.method == key);
    for (MethodCall msg in unhandled) {
      callback(msg);
    }
  }

  void unregisterCallback(String key) {
    _callbacks.remove(key);
  }

  void exitEditMode() {
    OverlayWindowUtils().disableEditMode();
    _editMode.sink.add(false);
  }

  Future<void> saveRect(OverlayFeatures key, Rect rect) async {
    return await _appRepository.saveRect(key.name, rect);
  }

  Future<void> _messageHandler(MethodCall value) async {
    if (_callbacks.containsKey(value.method)) {
      _callbacks[value.method]!(value);
    } else {
      _unhandledMessages.add(value);
      if (_unhandledMessages.length > _maxUnhandledMessages) {
        _unhandledMessages.removeAt(0);
      }
    }
  }

  void _registerCallbacks() {
    registerCallback(key: "set window", callback: _setWindow);
    registerCallback(key: "edit mode", callback: _setEditMode);
    registerCallback(key: "settings", callback: _settingsCallback);
    registerCallback(key: "reset widgets", callback: _resetWidgetsCallback);
    registerCallback(key: "notification", callback: _notify);
  }

  void _setWindow(MethodCall value) {
    final display = MonitorDevice.fromJson(jsonDecode(value.arguments));
    _loading.sink.add(true);
    final rect = display.rect;
    final applied = OverlayWindowUtils().setOverlayMode(rect: rect);
    Future.delayed(
      const Duration(milliseconds: 300),
      () async {
        /* 창 이동 직후가 아니라 잠시 뒤에 처리되는 DPI 변경까지 흡수한 뒤 실제 영역을 보고한다.
           기존 로딩 해제 지연을 그대로 재사용해 별도 타이머를 만들지 않는다. */
        final verified = OverlayWindowUtils().ensureOverlayBounds(rect);
        _loading.sink.add(false);
        try {
          await _appRepository.reportWindowBounds(
            requested: rect,
            actual: verified.actual,
            corrected: applied.corrected || verified.corrected,
          );
        } catch (e) {
          /* 보고는 진단용이다. 실패해도 오버레이 동작에는 영향이 없으므로 삼킨다. */
          _log.fine('Failed to report window bounds: $e');
        }
      },
    );
  }

  void _setEditMode(MethodCall value) {
    _editMode.sink.add(true);
    OverlayWindowUtils().enableEditMode();
  }

  void _resetWidgetsCallback(MethodCall value) {
    _resetWidgets.sink.add(true);
  }

  void _settingsCallback(MethodCall value) {
    _settings.sink.add(OverlaySettings.fromJson(jsonDecode(value.arguments)));
  }

  void _notify(MethodCall value) {
    if (_settings.valueOrNull?.activationStatus[OverlayFeatures.notification] ??
        false) {
      final Map json = jsonDecode(value.arguments)..remove("route");
      final message = AppNotificationMessage.fromJson(json);
      if (_scaffoldMessengerKey.currentState != null) {
        final context = _scaffoldMessengerKey.currentState!.context;
        final screenSize = MediaQuery.sizeOf(context);
        _scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
          duration: AppTheme.snackBarDuration,
          content: SnackBarContent(
            data: message,
            textStyle: TextTheme.of(context).headlineMedium,
          ),
          margin: EdgeInsets.only(
            left: Dimens.snackBarHorizontalMarginValue(screenSize.width),
            right: Dimens.snackBarHorizontalMarginValue(screenSize.width),
            top: 0,
            bottom: screenSize.height * 0.05,
          ),
        ));
      }
    }
  }
}
