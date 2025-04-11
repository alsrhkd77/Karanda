import 'package:flutter/foundation.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/model/overlay_settings.dart';
import 'package:karanda/repository/overlay_repository.dart';

class OverlayController extends ChangeNotifier {
  final OverlayRepository _overlayRepository;

  OverlaySettings? overlaySettings;

  OverlayController({required OverlayRepository overlayRepository})
      : _overlayRepository = overlayRepository;

  Future<void> loadSettings() async {
    overlaySettings = await _overlayRepository.loadSettings();
    notifyListeners();
  }

  Future<void> switchEditMode() async {
    await _overlayRepository.switchEditMode();
  }

  Future<void> switchActivation(OverlayFeatures feature, bool status) async {
    if (overlaySettings != null) {
      if(status){
        overlaySettings!.activatedFeatures.add(feature);
      } else {
        overlaySettings!.activatedFeatures.remove(feature);
      }
      await _overlayRepository
          .sendActivationStatus(overlaySettings!.activationStatus);
      await _overlayRepository.saveSettings(overlaySettings!);
      notifyListeners();
    }
  }
}
