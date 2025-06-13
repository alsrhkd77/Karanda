import 'dart:async';

import 'package:flutter/material.dart';
import 'package:karanda/enums/recruitment_category.dart';
import 'package:karanda/model/adventurer_hub_settings.dart';
import 'package:karanda/model/world_boss_settings.dart';
import 'package:karanda/repository/adventurer_hub_repository.dart';
import 'package:karanda/service/world_boss_service.dart';
import 'package:karanda/ui/world_boss/widgets/add_notification_time_dialog.dart';

class NotificationSettingsController extends ChangeNotifier {
  final WorldBossService _worldBossService;
  final AdventurerHubRepository _adventurerHubRepository;
  late final StreamSubscription _worldBossSettings;
  late final StreamSubscription _adventurerHubSettings;

  WorldBossSettings? worldBossSettings;
  AdventurerHubSettings? adventurerHubSettings;

  NotificationSettingsController({
    required WorldBossService worldBossService,
    required AdventurerHubRepository adventurerHubRepository,
  })  : _worldBossService = worldBossService,
        _adventurerHubRepository = adventurerHubRepository {
    _worldBossSettings =
        _worldBossService.settingsStream.listen(_onWorldBossSettingsUpdate);
    _adventurerHubSettings = _adventurerHubRepository.settingsStream
        .listen(_onAdventurerHubSettingsUpdate);
  }

  Future<void> addNotificationTime(BuildContext context) async {
    if(worldBossSettings != null){
      final int? value = await showDialog(
        context: context,
        builder: (context) => AddNotificationTimeDialog(
          notificationTimes: worldBossSettings!.notificationTime.toList(),
        ),
      );
      if (value != null) {
        _worldBossService.addNotificationTime(value);
      }
    }
  }

  void removeNotificationTime(int value) {
    _worldBossService.removeNotificationTime(value);
  }

  void updateExcludedBoss(String value) {
    _worldBossService.updateExcludedBoss(value);
  }

  void setWorldBossNotify(bool value) {
    _worldBossService.setNotify(value);
  }

  void setAdventurerHubNotify(bool value){
    _adventurerHubRepository.setNotify(value);
  }
  void updateAdventurerHubExcludedCategory(RecruitmentCategory value){
    _adventurerHubRepository.updateExcludedCategory(value);
  }

  void _onWorldBossSettingsUpdate(WorldBossSettings value) {
    worldBossSettings = value;
    notifyListeners();
  }

  void _onAdventurerHubSettingsUpdate(AdventurerHubSettings value) {
    adventurerHubSettings = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _worldBossSettings.cancel();
    _adventurerHubSettings.cancel();
    super.dispose();
  }
}
