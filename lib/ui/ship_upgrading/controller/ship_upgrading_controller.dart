import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_settings.dart';
import 'package:karanda/repository/ship_upgrading_repository.dart';

class ShipUpgradingController extends ChangeNotifier {
  final ShipUpgradingRepository _repository;
  late final StreamSubscription _settings;

  ShipUpgradingSettings settings = ShipUpgradingSettings();

  ShipUpgradingController({required ShipUpgradingRepository repository})
      : _repository = repository{
    _settings = _repository.settingsStream.listen(onSettingsUpdate);
  }

  void loadData(){
    _repository.loadSettings();
    _repository.loadData();
  }

  void onSettingsUpdate(ShipUpgradingSettings value){
    settings = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _settings.cancel();
    super.dispose();
  }
}
