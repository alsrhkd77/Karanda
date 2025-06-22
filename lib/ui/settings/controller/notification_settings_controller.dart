import 'dart:async';

import 'package:flutter/material.dart';
import 'package:karanda/enums/recruitment_category.dart';
import 'package:karanda/model/party_finder_settings.dart';
import 'package:karanda/model/world_boss_settings.dart';
import 'package:karanda/repository/party_finder_repository.dart';
import 'package:karanda/service/world_boss_service.dart';
import 'package:karanda/ui/world_boss/widgets/add_notification_time_dialog.dart';

class NotificationSettingsController extends ChangeNotifier {
  final WorldBossService _worldBossService;
  final PartyFinderRepository _partyFinderRepository;
  late final StreamSubscription _worldBossSettings;
  late final StreamSubscription _partyFinderSettings;

  WorldBossSettings? worldBossSettings;
  PartyFinderSettings? partyFinderSettings;

  NotificationSettingsController({
    required WorldBossService worldBossService,
    required PartyFinderRepository partyFinderRepository,
  })  : _worldBossService = worldBossService,
        _partyFinderRepository = partyFinderRepository {
    _worldBossSettings =
        _worldBossService.settingsStream.listen(_onWorldBossSettingsUpdate);
    _partyFinderSettings = _partyFinderRepository.settingsStream
        .listen(_onPartyFinderSettingsUpdate);
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

  void setPartyFinderNotify(bool value){
    _partyFinderRepository.setNotify(value);
  }
  void updatePartyFinderExcludedCategory(RecruitmentCategory value){
    _partyFinderRepository.updateExcludedCategory(value);
  }

  void _onWorldBossSettingsUpdate(WorldBossSettings value) {
    worldBossSettings = value;
    notifyListeners();
  }

  void _onPartyFinderSettingsUpdate(PartyFinderSettings value) {
    partyFinderSettings = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _worldBossSettings.cancel();
    _partyFinderSettings.cancel();
    super.dispose();
  }
}
