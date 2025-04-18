import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/model/app_settings.dart';
import 'package:karanda/service/app_settings_service.dart';

class WindowsSettingsController extends ChangeNotifier {
  final AppSettingsService _settingsService;
  late final StreamSubscription _appSettings;

  AppSettings? appSettings;

  bool get startMinimized => appSettings?.startMinimized ?? false;

  bool get useTrayMode => appSettings?.useTrayMode ?? false;

  WindowsSettingsController({required AppSettingsService settingsService})
      : _settingsService = settingsService {
    _appSettings =
        _settingsService.appSettingsStream.listen(_onAppSettingsUpdate);
  }

  void setUseTrayMode(bool value) {
    _settingsService.setUseTrayMode(value);
  }

  void setStartMinimized(bool value) {
    _settingsService.setStartMinimized(value);
  }

  void _onAppSettingsUpdate(AppSettings value) {
    appSettings = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _appSettings.cancel();
    super.dispose();
  }
}
