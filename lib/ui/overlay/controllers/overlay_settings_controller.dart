import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/model/monitor_device.dart';
import 'package:karanda/model/overlay_settings.dart';
import 'package:karanda/repository/overlay_repository.dart';

class OverlaySettingsController extends ChangeNotifier {
  final OverlayRepository _overlayRepository;
  late final StreamSubscription _overlaySettings;

  OverlaySettings? overlaySettings;
  List<MonitorDevice>? monitorList;

  OverlaySettingsController({required OverlayRepository overlayRepository})
      : _overlayRepository = overlayRepository {
    _overlaySettings =
        _overlayRepository.settingsStream.listen(_onSettingsUpdate);
  }

  void selectMonitor(MonitorDevice? value) {
    if(value != null && overlaySettings!.monitorDevice != value){
      _overlayRepository.changeMonitor(value);
    }
  }

  Future<void> getMonitorList() async {
    monitorList = await _overlayRepository.getMonitorList();
  }

  void _onSettingsUpdate(OverlaySettings value) {
    overlaySettings = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _overlaySettings.cancel();
    super.dispose();
  }
}
