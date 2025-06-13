import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/enums/features.dart';
import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/model/app_notification_message.dart';
import 'package:karanda/model/world_boss.dart';
import 'package:karanda/model/world_boss_schedule.dart';
import 'package:karanda/model/world_boss_schedule_set.dart';
import 'package:karanda/model/world_boss_settings.dart';
import 'package:karanda/repository/app_notification_repository.dart';
import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/overlay_repository.dart';
import 'package:karanda/repository/time_repository.dart';
import 'package:karanda/repository/world_boss_repository.dart';
import 'package:karanda/utils/extension/date_time_extension.dart';
import 'package:rxdart/rxdart.dart';

class WorldBossService {
  final AppSettingsRepository _settingsRepository;
  final WorldBossRepository _worldBossRepository;
  final TimeRepository _timeRepository;
  final AppNotificationRepository _notificationRepository;
  final OverlayRepository _overlayRepository;
  List<WorldBossSchedule> schedule = [];
  final _currentSchedule = BehaviorSubject<WorldBossScheduleSet>();
  final List<int> notified = [];
  bool spawned = false; //current boss spawn status

  WorldBossService({
    required AppSettingsRepository settingsRepository,
    required WorldBossRepository worldBossRepository,
    required TimeRepository timeRepository,
    required AppNotificationRepository notificationRepository,
    required OverlayRepository overlayRepository,
  })  : _settingsRepository = settingsRepository,
        _worldBossRepository = worldBossRepository,
        _timeRepository = timeRepository,
        _notificationRepository = notificationRepository,
        _overlayRepository = overlayRepository {
    _timeRepository.utcTimeStream.listen(_checkBossSpawn);
    filteredBossDataStream.listen(_onFilteredBossDataUpdate);
    _settingsRepository.settingsStream
        .map((settings) => settings.region)
        .distinct()
        .listen((region) => _worldBossRepository.getBossData(region));
    _worldBossRepository.getSettings();
  }

  Stream<WorldBossScheduleSet> get currentSchedule => _currentSchedule.stream;

  Stream<WorldBossSettings> get settingsStream =>
      _worldBossRepository.settingsStream;

  Stream<List<WorldBoss>> get fixedBossesStream =>
      _worldBossRepository.bossDataStream.map(_fixedBossesFilter);

  /// 제외할 보스 목록에 포함되지 않은 보스
  Stream<List<WorldBoss>> get filteredBossDataStream =>
      _worldBossRepository.bossDataStream.map(_activatedBossesFilter);

  List<WorldBossSchedule> _buildSchedule(List<WorldBoss> data) {
    final List<WorldBossSchedule> result = [];
    for (WorldBoss boss in data) {
      final index = result.indexWhere((item) =>
          item.spawnTime.weekday == boss.weekday &&
          TimeOfDay.fromDateTime(item.spawnTime) == boss.spawnTime);
      if (index < 0) {
        final days = boss.weekday - _timeRepository.utcTime.weekday;
        DateTime spawnTime = _timeRepository.utcTime
            .toDate()
            .copyWith(hour: boss.spawnTime.hour, minute: boss.spawnTime.minute)
            .add(Duration(days: days));
        if (spawnTime.isBefore(_timeRepository.utcTime)) {
          spawnTime = spawnTime.add(const Duration(days: 7));
        }
        result.add(WorldBossSchedule(
          spawnTime: spawnTime,
          bosses: [boss],
        ));
      } else {
        result[index].bosses.add(boss);
      }
    }
    /* 서머타임 체크 */
    for (final value in result) {
      if (value.bosses.first.region == BDORegion.NA &&
          value.spawnTime.isInPDT) {
        value.spawnTime.add(const Duration(hours: 1));
      } else if (value.bosses.first.region == BDORegion.EU &&
          value.spawnTime.isInCEST) {
        value.spawnTime.add(const Duration(hours: 1));
      } else {
        break;
      }
    }
    result.sort(_sortSchedule);
    return result.where((value) => value.activatedBosses.isNotEmpty).toList();
  }

  void _checkBossSpawn(DateTime now) {
    if (_currentSchedule.valueOrNull != null &&
        _worldBossRepository.settings != null) {
      final notificationTime =
          _worldBossRepository.settings?.notificationTime.toList() ?? [];
      final current = _currentSchedule.value.current;
      final diff = current.spawnTime.difference(now);
      if (diff.inSeconds <= -60) {
        _updateNextBoss();
      } else if (diff.inSeconds < 0 && !spawned) {
        spawned = true;
        _alertSpawn(
            current.activatedBosses.map((boss) => boss.name.tr()).join(", "));
      } else if (notificationTime.contains(diff.inMinutes) &&
          !notified.contains(diff.inMinutes)) {
        notified.add(diff.inMinutes);
        _alertTimeRemaining(
          current.activatedBosses.map((boss) => boss.name.tr()).join(", "),
          diff.inMinutes,
        );
      }
    }
  }

  void _updateNextBoss() {
    notified.clear();
    spawned = false;
    final data = schedule.removeAt(0);
    data.spawnTime = data.spawnTime.add(const Duration(days: 7));
    schedule.add(data);
    if (schedule[1].activatedBosses.isEmpty) {
      schedule.removeAt(1);
    }
    _reflectUpdatedSchedules();
  }

  void _onFilteredBossDataUpdate(List<WorldBoss> data) {
    schedule = _buildSchedule(data);
    _reflectUpdatedSchedules();
  }

  void _reflectUpdatedSchedules() {
    final data = WorldBossScheduleSet(
      previous: schedule.last.toPreviousSchedule(),
      current: schedule.first,
      next: schedule[1],
    );
    _currentSchedule.sink.add(data);
    _overlayRepository.sendToOverlay(
      method: OverlayFeatures.worldBoss.name,
      data: jsonEncode(data.current.toJson()),
    );
  }

  void _alertSpawn(String bossNames) {
    if (_worldBossRepository.settings?.notify ?? false) {
      _notificationRepository.addNotification(AppNotificationMessage(
        feature: Features.worldBoss,
        contentsKey: "world boss spawn",
        contentsArgs: [bossNames],
        mdContents: true,
      ));
    }
  }

  void _alertTimeRemaining(String bossNames, int timeRemaining) {
    if (_worldBossRepository.settings?.notify ?? false) {
      _notificationRepository.addNotification(AppNotificationMessage(
        feature: Features.worldBoss,
        contentsKey: "world boss time remaining",
        contentsArgs: [bossNames, timeRemaining.toString()],
        mdContents: true,
      ));
    }
  }

  void addNotificationTime(int value) {
    if (_worldBossRepository.settings != null &&
        _worldBossRepository.settings!.notificationTime.length < 10) {
      _worldBossRepository.addNotificationTime(value);
    }
  }

  void removeNotificationTime(int value) {
    if (_worldBossRepository.settings != null) {
      _worldBossRepository.removeNotificationTime(value);
    }
  }

  void updateExcludedBoss(String value) {
    if (_worldBossRepository.settings?.excluded.contains(value) ?? false) {
      _worldBossRepository.removeExcludedBoss(value);
    } else {
      _worldBossRepository.addExcludedBoss(value);
    }
  }

  void setNotify(bool value) {
    _worldBossRepository.setNotify(value);
  }

  int _sortSchedule(WorldBossSchedule a, WorldBossSchedule b) {
    return a.spawnTime.compareTo(b.spawnTime);
  }

  List<WorldBoss> _fixedBossesFilter(List<WorldBoss> bosses) {
    final List<WorldBoss> result = [];
    for (WorldBoss boss in bosses) {
      if (!result.any((data) => data.name == boss.name)) {
        result.add(boss);
      }
    }
    return result;
  }

  /// 제외된 보스를 제거
  List<WorldBoss> _activatedBossesFilter(List<WorldBoss> bosses) {
    if (_worldBossRepository.settings == null) {
      return bosses;
    }
    return bosses.where((boss) {
      return !(_worldBossRepository.settings!.excluded.contains(boss.name));
    }).toList();
  }
}
