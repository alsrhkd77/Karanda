import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:karanda/data_source/overlay_api.dart';
import 'package:karanda/data_source/overlay_settings_data_source.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/model/overlay_settings.dart';

class OverlayRepository {
  final OverlaySettingsDataSource _overlaySettingsDataSource;
  final OverlayApi _overlayApi;
  final Completer<WindowController> _completer = Completer();

  OverlayRepository(
      {required OverlaySettingsDataSource overlaySettingsDataSource,
      required OverlayApi overlayApi})
      : _overlaySettingsDataSource = overlaySettingsDataSource,
        _overlayApi = overlayApi;

  Future<WindowController> get _windowController => _completer.future;

  Future<void> startOverlay() async {
    if (kIsWeb || !Platform.isWindows) return;
    final windowController = await _overlayApi.startOverlay();
    _overlayApi.sendToOverlay(
      windowController: windowController,
      method: "initialize",
      data: "",
    );
    await Future.delayed(const Duration(seconds: 1));
    _completer.complete(windowController);
  }

  Future<void> sendToOverlay({required String method, String data = ""}) async {
    if(kIsWeb || !Platform.isWindows) return;
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

  Future<void> sendActivationStatus(Map<OverlayFeatures, bool> value) async {
    final activationStatus = value.map(
      (key, value) => MapEntry(key.name, value),
    );
    await sendToOverlay(
      method: "activation status",
      data: jsonEncode(activationStatus),
    );
  }

  Future<OverlaySettings> loadSettings() async {
    return await _overlaySettingsDataSource.loadSettings();
  }

  Future<void> saveSettings(OverlaySettings value) async {
    //await sendActivationStatus(value.activationStatus);
    await _overlaySettingsDataSource.saveSettings(value);
  }
}
