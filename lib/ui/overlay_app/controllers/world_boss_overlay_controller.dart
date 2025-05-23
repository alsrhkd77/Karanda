import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:karanda/model/overlay_settings.dart';
import 'package:karanda/repository/time_repository.dart';
import 'package:karanda/ui/overlay_app/controllers/overlay_widget_controller.dart';
import 'dart:developer' as developer;
import '../../../model/world_boss_schedule.dart';

class WorldBossOverlayController extends OverlayWidgetController {
  final TimeRepository _timeRepository;
  late final StreamSubscription _time;
  late final StreamSubscription _settings;

  WorldBossSchedule? schedule;
  Duration timeRemaining = Duration.zero;
  bool showName = false;

  WorldBossOverlayController(
      {required super.key,
      required super.defaultRect,
      required super.constraints,
      required super.service,
      required TimeRepository timeRepository})
      : _timeRepository = timeRepository {
    _time = _timeRepository.realTimeStream.listen(_onTimeUpdate);
    _settings = service.settingsStream.listen(_onSettingsUpdate);
    service.registerCallback(key: key.name, callback: _onWorldBossMessage);
  }

  void _onWorldBossMessage(MethodCall call) {
    try {
      schedule = WorldBossSchedule.fromJson(jsonDecode(call.arguments));
      notifyListeners();
    } catch (e) {
      developer.log(
          "Failed to parse [WorldBossSchedule] message\n${call.arguments}");
    }
  }

  void _onSettingsUpdate(OverlaySettings value) {
    showName = value.showWorldBossName;
    notifyListeners();
  }

  void _onTimeUpdate(DateTime value) {
    if (schedule != null) {
      timeRemaining = schedule!.spawnTime.difference(value);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    service.unregisterCallback(key.name);
    _time.cancel();
    _settings.cancel();
    super.dispose();
  }
}
