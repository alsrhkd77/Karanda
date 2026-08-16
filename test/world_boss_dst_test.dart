import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/world_boss.dart';
import 'package:karanda/model/world_boss_schedule.dart';
import 'package:karanda/utils/extension/date_time_extension.dart';

/// `WorldBossService._buildSchedule`의 서머타임 보정 루프를 그대로 복제한 순수 함수.
///
/// **주의**: `lib/service/world_boss_service.dart`와 반드시 동기화 유지.
/// 방향: NA=PST/UTC-8, EU=CET/UTC+1(표준시) 기준으로 저장된 데이터에서, 서머타임 기간은
/// 로컬 벽시계 고정을 가정해 저장값보다 실제 UTC가 1시간 이르므로 뺀다.
/// 2026-08-15 NA 가모스 실측(저장 20:00 UTC, 실제 약 19:00 UTC)으로 방향을 확인했다.
List<WorldBossSchedule> applyDstCorrection(List<WorldBossSchedule> result) {
  for (final value in result) {
    if (value.bosses.first.region == BDORegion.NA && value.spawnTime.isInPDT) {
      value.spawnTime = value.spawnTime.subtract(const Duration(hours: 1));
    } else if (value.bosses.first.region == BDORegion.EU &&
        value.spawnTime.isInCEST) {
      value.spawnTime = value.spawnTime.subtract(const Duration(hours: 1));
    }
  }
  return result;
}

WorldBoss naBoss() {
  return WorldBoss(
    name: 'garmoth',
    weekday: 6,
    spawnTime: const TimeOfDay(hour: 12, minute: 0),
    region: BDORegion.NA,
  );
}

WorldBoss euBoss() {
  return WorldBoss(
    name: 'garmoth',
    weekday: 6,
    spawnTime: const TimeOfDay(hour: 21, minute: 0),
    region: BDORegion.EU,
  );
}

WorldBoss krBoss() {
  return WorldBoss(
    name: 'garmoth',
    weekday: 6,
    spawnTime: const TimeOfDay(hour: 0, minute: 15),
    region: BDORegion.KR,
  );
}

WorldBossSchedule scheduleAt(DateTime utcSpawnTime, WorldBoss boss) {
  return WorldBossSchedule(spawnTime: utcSpawnTime, bosses: [boss]);
}

void main() {
  // 2026-08-15는 NA(PDT)·EU(CEST) 모두 서머타임 기간이다 (실측 확인 시점).
  final duringDst = DateTime.utc(2026, 8, 15, 20, 0);
  // 1월은 두 지역 모두 표준시 기간이다.
  final outsideDst = DateTime.utc(2026, 1, 15, 20, 0);

  group('DateTimeExtension DST 판정', () {
    test('8월은 PDT/CEST 기간으로 판정된다', () {
      expect(duringDst.isInPDT, isTrue);
      expect(duringDst.isInCEST, isTrue);
    });

    test('1월은 PDT/CEST 기간이 아니다', () {
      expect(outsideDst.isInPDT, isFalse);
      expect(outsideDst.isInCEST, isFalse);
    });
  });

  group('applyDstCorrection', () {
    test('NA + 서머타임 기간이면 1시간을 뺀다', () {
      final schedule = [scheduleAt(duringDst, naBoss())];
      final result = applyDstCorrection(schedule);
      expect(result.single.spawnTime, duringDst.subtract(const Duration(hours: 1)));
    });

    test('EU + 서머타임 기간이면 1시간을 뺀다', () {
      final schedule = [scheduleAt(duringDst, euBoss())];
      final result = applyDstCorrection(schedule);
      expect(result.single.spawnTime, duringDst.subtract(const Duration(hours: 1)));
    });

    test('서머타임 기간이 아니면 보정하지 않는다', () {
      final schedule = [scheduleAt(outsideDst, naBoss())];
      final result = applyDstCorrection(schedule);
      expect(result.single.spawnTime, outsideDst);
    });

    test('KR은 서머타임 보정 대상이 아니다', () {
      final schedule = [scheduleAt(duringDst, krBoss())];
      final result = applyDstCorrection(schedule);
      expect(result.single.spawnTime, duringDst);
    });

    test('지역이 섞여 있어도(보정 대상이 먼저 걸러지지 않아도) 전원 개별 판정된다', () {
      // 과거 코드는 조건 불일치 시 break로 루프 전체를 중단시켰다 — 회귀 방지.
      final schedule = [
        scheduleAt(outsideDst, krBoss()), // 보정 없음 (KR)
        scheduleAt(duringDst, naBoss()), // 보정 필요 (NA, DST)
      ];
      final result = applyDstCorrection(schedule);
      expect(result[0].spawnTime, outsideDst);
      expect(result[1].spawnTime, duringDst.subtract(const Duration(hours: 1)));
    });
  });
}
