import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/model/bartering/bartering_mastery.dart';
import 'package:karanda/model/bartering/bartering_settings.dart';
import 'package:karanda/model/bartering/ship_profile.dart';
import 'package:karanda/repository/bartering_repository.dart';

class BarteringSettingsController extends ChangeNotifier {
  final BarteringRepository _repository;
  final void Function() _removeFailedSnackbar;
  late final StreamSubscription<BarteringSettings> _settings;
  BarteringSettings? settings;
  List<BarteringMastery> mastery = [];

  BarteringSettingsController({
    required BarteringRepository repository,
    required void Function() removeFailedSnackbar,
  })  : _repository = repository,
        _removeFailedSnackbar = removeFailedSnackbar {
    _settings = _repository.settingsStream.listen(_onSettingsUpdate);
    _getMasteryData();
  }

  void onMasterySelected(BarteringMastery? value) {
    if (settings != null && value != null) {
      settings?.mastery = value;
      _repository.saveSettings(settings!);
    }
  }

  void useValuePack(bool? value) {
    if (settings != null && value != null) {
      settings!.valuePack = value;
      _repository.saveSettings(settings!);
    }
  }

  bool addShipProfile(ShipProfile value) {
    final profiles = settings?.shipProfiles ?? [];
    if (settings != null) {
      if (!profiles.any((item) => item.name == value.name)) {
        settings!.shipProfiles.add(value);
        _repository.saveSettings(settings!);
        return true;
      }
    }
    return false;
  }

  bool updateShipProfile({
    required int index,
    required ShipProfile shipProfile,
  }) {
    final profiles = List<ShipProfile>.of(settings?.shipProfiles ?? []);
    if (settings != null && profiles.length > index) {
      profiles.removeAt(index);
      if (!profiles.any((item) => item.name == shipProfile.name)) {
        settings!.shipProfiles[index] = shipProfile;
        _repository.saveSettings(settings!);
        return true;
      }
    }
    return false;
  }

  void removeShipProfile(int index) {
    if (settings != null) {
      if(settings!.shipProfiles.length > 1){
        settings!.shipProfiles.removeAt(index);
        settings!.lastSelectedShipIndex = 0;
        _repository.saveSettings(settings!);
      } else {
        _removeFailedSnackbar();
      }
    }
  }

  void _onSettingsUpdate(BarteringSettings value) {
    settings = value;
    notifyListeners();
  }

  Future<void> _getMasteryData() async {
    mastery = await _repository.mastery();
    notifyListeners();
  }

  @override
  void dispose() {
    _settings.cancel();
    super.dispose();
  }
}
