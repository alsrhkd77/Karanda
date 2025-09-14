import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
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

  OverlayRepository(
      {required OverlaySettingsDataSource overlaySettingsDataSource,
      required OverlayApi overlayApi})
      : _overlaySettingsDataSource = overlaySettingsDataSource,
        _overlayApi = overlayApi {
    _settings.stream.listen(saveSettings);
  }

  Future<WindowController> get _windowController => _completer.future;

  Stream<OverlaySettings> get settingsStream => _settings.stream;

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
