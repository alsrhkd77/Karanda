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
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/snack_bar_content.dart';
import 'package:karanda/utils/overlay_window_utils/overlay_window_utils.dart';

import 'package:rxdart/rxdart.dart';

class OverlayAppService {
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
    final unhandled = _unhandledMessages.where((msg) => msg.method == key);
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

  Future<Rect?> loadRect(OverlayFeatures key) async {
    return await _appRepository.loadRect(key.name);
  }

  Future<void> _messageHandler(MethodCall value) async {
    if (_callbacks.containsKey(value.method)) {
      _callbacks[value.method]!(value);
    } else {
      _unhandledMessages.add(value);
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
    OverlayWindowUtils().setOverlayMode(rect: display.rect);
    Future.delayed(
      const Duration(milliseconds: 300),
      () => _loading.sink.add(false),
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
