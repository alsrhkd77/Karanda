import 'package:flutter/foundation.dart';
import 'package:karanda/model/user_fcm_settings.dart';
import 'package:karanda/service/app_settings_service.dart';

class UserFcmSettingsController extends ChangeNotifier {
  final AppSettingsService _appSettingsService;
  UserFcmSettings? fcmSettings;

  bool initialized = false;

  UserFcmSettingsController({
    required AppSettingsService appSettingsService,
  }) : _appSettingsService = appSettingsService;

  bool get activate => fcmSettings != null;

  Future<void> loadData() async {
    fcmSettings = await _appSettingsService.getFcmSettings();
    initialized = true;
    notifyListeners();
  }

  Future<bool> activatePushNotifications() async {
    fcmSettings = await _appSettingsService.activatePushNotification();
    notifyListeners();
    return activate;
  }

  Future<void> deactivatePushNotifications() async {
    await _appSettingsService.deactivatePushNotification();
    fcmSettings = null;
    notifyListeners();
  }

  Future<void> switchPartyFinderStatus(bool? value) async {
    if(value != null && fcmSettings != null){
      fcmSettings!.partyFinder = value;
      fcmSettings = await _appSettingsService.saveFcmSettings(fcmSettings!);
      notifyListeners();
    }
  }
}
