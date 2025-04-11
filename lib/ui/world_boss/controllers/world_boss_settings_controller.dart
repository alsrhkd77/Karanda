import 'dart:async';

import 'package:flutter/material.dart';
import 'package:karanda/model/world_boss.dart';
import 'package:karanda/model/world_boss_settings.dart';
import 'package:karanda/service/world_boss_service.dart';
import 'package:karanda/ui/world_boss/widgets/add_notification_time_dialog.dart';

class WorldBossSettingsController extends ChangeNotifier {
  final WorldBossService _worldBossService;
  late final StreamSubscription _settings;
  late final StreamSubscription _fixedBosses;

  WorldBossSettings settings = WorldBossSettings();
  List<WorldBoss> fixedBosses = [];

  WorldBossSettingsController({required WorldBossService worldBossService})
      : _worldBossService = worldBossService {
    _settings = _worldBossService.settingsStream.listen(_onSettingsUpdate);
    _fixedBosses =
        _worldBossService.fixedBossesStream.listen(_onFixedBossesUpdate);
  }

  Future<void> addNotificationTime(BuildContext context) async {
    final int? value = await showDialog(
      context: context,
      builder: (context) => AddNotificationTimeDialog(
        notificationTimes: settings.notificationTime.toList(),
      ),
    );
    if (value != null) {
      _worldBossService.addNotificationTime(value);
    }
  }

  void removeNotificationTime(int value) {
    _worldBossService.removeNotificationTime(value);
  }

  void updateExcludedBoss(String value) {
    _worldBossService.updateExcludedBoss(value);
  }

  void setNotify(bool value) {
    _worldBossService.setNotify(value);
  }

  void _onSettingsUpdate(WorldBossSettings value) {
    settings = value;
    notifyListeners();
  }

  void _onFixedBossesUpdate(List<WorldBoss> value) {
    fixedBosses = value;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _settings.cancel();
    await _fixedBosses.cancel();
    super.dispose();
  }
}
