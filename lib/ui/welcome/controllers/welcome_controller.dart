import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/app_settings.dart';
import 'package:karanda/repository/app_settings_repository.dart';

class WelcomeController extends ChangeNotifier {
  final AppSettingsRepository _appSettingsRepository;
  late final StreamSubscription _region;

  BDORegion? region;

  WelcomeController({required AppSettingsRepository appSettingsRepository})
      : _appSettingsRepository = appSettingsRepository {
    _region = _appSettingsRepository.settingsStream.listen(_onSettingsUpdate);
  }

  void setRegion(BDORegion? value) {
    if(value != null){
      _appSettingsRepository.setRegion(value);
    }
  }

  void _onSettingsUpdate(AppSettings value) {
    region = value.region;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _region.cancel();
    super.dispose();
  }
}
