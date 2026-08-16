import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:karanda/model/overlay_settings.dart';
import 'package:karanda/repository/time_repository.dart';
import 'package:karanda/ui/overlay_app/controllers/overlay_widget_controller.dart';
import 'package:logging/logging.dart';
import '../../../model/world_boss_schedule.dart';

/// 월드보스 오버레이 운영 로그.
final _log = Logger('world_boss');

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
    } catch (e, s) {
      _log.warning('Failed to parse world boss schedule message', e, s);
    }
  }

  void _onSettingsUpdate(OverlaySettings value) {
    showName = value.showWorldBossName;
    notifyListeners();
  }

  void _onTimeUpdate(DateTime value) {
    if (schedule != null) {
      timeRemaining = schedule!.spawnTime.difference(value);
      notifyIfVisible();
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
