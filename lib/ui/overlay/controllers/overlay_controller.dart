import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/model/overlay_settings.dart';
import 'package:karanda/repository/overlay_repository.dart';

class OverlayController extends ChangeNotifier {
  final OverlayRepository _overlayRepository;
  late final StreamSubscription _overlaySettings;

  OverlaySettings? overlaySettings;

  OverlayController({required OverlayRepository overlayRepository})
      : _overlayRepository = overlayRepository {
    _overlaySettings =
        _overlayRepository.settingsStream.listen(_onSettingsUpdate);
  }

  void _onSettingsUpdate(OverlaySettings value) {
    overlaySettings = value;
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

  @override
  void dispose() {
    _overlaySettings.cancel();
    super.dispose();
  }
}
