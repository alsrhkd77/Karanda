import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/model/mirroring_settings.dart';
import 'package:karanda/model/overlay_settings.dart';
import 'package:karanda/model/window_info.dart';
import 'package:karanda/repository/overlay_repository.dart';

class OverlayController extends ChangeNotifier {
  final OverlayRepository _overlayRepository;
  late final StreamSubscription _overlaySettings;
  late final StreamSubscription _mirroringSource;

  OverlaySettings? overlaySettings;

  /// 현재 선택된 미러링 소스 (세션 한정)
  WindowInfo? mirroringSource;

  OverlayController({required OverlayRepository overlayRepository})
      : _overlayRepository = overlayRepository {
    _overlaySettings =
        _overlayRepository.settingsStream.listen(_onSettingsUpdate);
    _mirroringSource =
        _overlayRepository.mirroringSourceStream.listen(_onMirroringSourceUpdate);
  }

  void _onSettingsUpdate(OverlaySettings value) {
    overlaySettings = value;
    notifyListeners();
  }

  void _onMirroringSourceUpdate(WindowInfo? value) {
    mirroringSource = value;
    notifyListeners();
  }

  Future<void> switchEditMode() async {
    await _overlayRepository.switchEditMode();
  }

  Future<void> switchActivation(OverlayFeatures feature, bool status) async {
    if (status) {
      _overlayRepository.activate(feature);
    } else {
      _overlayRepository.deactivate(feature);
    }
  }

  void showWorldBossName(bool value){
    _overlayRepository.showWorldBossName(value);
  }

  void setOpacity(OverlayFeatures feature, double value) {
    _overlayRepository.setOpacity(feature, (value * 255).round());
  }

  List<WindowInfo> getMirrorableWindows() {
    return _overlayRepository.getMirrorableWindows();
  }

  void setMirroringSource(WindowInfo? value) {
    _overlayRepository.setMirroringSource(value);
  }

  void updateMirroringSettings(MirroringSettings value) {
    _overlayRepository.updateMirroringSettings(value);
  }

  @override
  void dispose() {
    _overlaySettings.cancel();
    _mirroringSource.cancel();
    super.dispose();
  }
}
