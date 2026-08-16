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
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

/// 월드 보스 기능 운영 로그.
final _log = Logger('world_boss');

class WorldBossService {
  final AppSettingsRepository _settingsRepository;
  final WorldBossRepository _worldBossRepository;
  final TimeRepository _timeRepository;
  final AppNotificationRepository _notificationRepository;
  final OverlayRepository _overlayRepository;
  List<WorldBossSchedule> schedule = [];

  /// 표시할 스케줄이 없는 상태(예: 사용자가 보스를 전부 제외)를 null로 표현한다.
  /// 예외를 던지는 대신 이 상태를 정상 값으로 다루어야, 500ms 타이머([_checkBossSpawn])가
  /// 낡은 값을 보고 무한히 재시도하는 것을 막을 수 있다.
  final _currentSchedule = BehaviorSubject<WorldBossScheduleSet?>();
  final List<int> notified = [];
  bool spawned = false; //current boss spawn status

  /// "스케줄 없음" 상태 진입 로그를 1회만 남기기 위한 플래그.
  bool _scheduleEmptyLogged = false;

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
        .listen((region) {
      _log.info('Load world boss data (region: ${region.name})');
      _worldBossRepository.getBossData(region);
    });
    _worldBossRepository.getSettings();
  }

  Stream<WorldBossScheduleSet?> get currentSchedule => _currentSchedule.stream;

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
    /* 서머타임 체크
     * 타임테이블 데이터는 표준시(NA=PST/UTC-8, EU=CET/UTC+1) 기준으로 저장돼 있고,
     * 게임은 서머타임 기간에도 로컬 벽시계 시각을 고정 유지한다. 따라서 서머타임 기간의
     * 실제 UTC 스폰 시각은 저장된 표준시 기준 UTC보다 1시간 이르다 — 빼야 한다.
     * (2026-08-15 NA 가모스 실측: 저장값 20:00 UTC, 실제 스폰 약 19:00 UTC로 확인.)
     * DateTime은 불변이라 반환값을 반드시 재대입해야 한다.
     * 지역은 그룹마다 바뀌지 않으므로(한 번에 한 지역만 조회) break 없이 전원을 검사한다. */
    for (final value in result) {
      if (value.bosses.first.region == BDORegion.NA &&
          value.spawnTime.isInPDT) {
        value.spawnTime = value.spawnTime.subtract(const Duration(hours: 1));
      } else if (value.bosses.first.region == BDORegion.EU &&
          value.spawnTime.isInCEST) {
        value.spawnTime = value.spawnTime.subtract(const Duration(hours: 1));
      }
    }
    result.sort(_sortSchedule);
    return result.where((value) => value.activatedBosses.isNotEmpty).toList();
  }

  void _checkBossSpawn(DateTime now) {
    final currentSet = _currentSchedule.valueOrNull;
    if (currentSet == null || _worldBossRepository.settings == null) return;

    final notificationTime =
        _worldBossRepository.settings?.notificationTime.toList() ?? [];
    final current = currentSet.current;
    final diff = current.spawnTime.difference(now);
    if (diff.inSeconds <= -60) {
      _updateNextBoss();
    } else if (diff.inSeconds < 0 && !spawned) {
      spawned = true;
      _alertSpawn(
          current.activatedBosses.map((boss) => boss.name.tr()).join(", "));
    } else if (notificationTime.contains(diff.inMinutes + 1) &&
        !notified.contains(diff.inMinutes)) {
      notified.add(diff.inMinutes);
      _alertTimeRemaining(
        current.activatedBosses.map((boss) => boss.name.tr()).join(", "),
        diff.inMinutes + 1,
      );
    }
  }

  void _updateNextBoss() {
    // 표시할 그룹이 2개 미만이면 회전할 대상이 없다. 여기서 막지 않으면
    // removeAt(0)/schedule[1]에서 RangeError가 나고, 그 예외 때문에 _currentSchedule이
    // 낡은 값으로 남아 다음 틱에도 같은 조건이 반복되는 무한 루프가 된다.
    if (schedule.length < 2) return;
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
    // 사용자가 보스를 전부(또는 거의 전부) 제외하면 표시할 그룹이 2개 미만일 수 있다.
    // 이는 예외 상황이 아니라 "표시할 보스 없음"이라는 정상 상태이므로 null로 표현한다.
    if (schedule.length < 2) {
      if (!_scheduleEmptyLogged) {
        _scheduleEmptyLogged = true;
        _log.info('World boss schedule is empty (all bosses excluded)');
      }
      _currentSchedule.sink.add(null);
      return;
    }
    _scheduleEmptyLogged = false;

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
      _log.info('World boss spawn alert ($bossNames)');
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
      _log.info('World boss reminder ($bossNames, ${timeRemaining}m left)');
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
      _log.info('Setting changed: add world boss notification time (${value}m)');
      _worldBossRepository.addNotificationTime(value);
    }
  }

  void removeNotificationTime(int value) {
    if (_worldBossRepository.settings != null) {
      _log.info('Setting changed: remove world boss notification time (${value}m)');
      _worldBossRepository.removeNotificationTime(value);
    }
  }

  void updateExcludedBoss(String value) {
    if (_worldBossRepository.settings?.excluded.contains(value) ?? false) {
      _log.info('Setting changed: include world boss ($value)');
      _worldBossRepository.removeExcludedBoss(value);
    } else {
      _log.info('Setting changed: exclude world boss ($value)');
      _worldBossRepository.addExcludedBoss(value);
    }
  }

  void setNotify(bool value) {
    _log.info('Setting changed: world boss notify = $value');
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
