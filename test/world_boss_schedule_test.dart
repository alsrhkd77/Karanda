import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/world_boss.dart';
import 'package:karanda/model/world_boss_schedule.dart';
import 'package:karanda/model/world_boss_schedule_set.dart';

/// `WorldBossService._updateNextBoss`/`_reflectUpdatedSchedules`의 회전·조립 로직을
/// 그대로 복제한 순수 함수. 서비스는 여러 Repository를 생성자 주입받아 인스턴스화가
/// 어려우므로, 여기서는 인덱스 접근 안전성(RangeError 방지)만을 검증 대상으로 삼는다.
///
/// **주의**: `lib/service/world_boss_service.dart`의 실제 구현과 반드시 동기화 유지.
List<WorldBossSchedule> rotate(List<WorldBossSchedule> schedule) {
  if (schedule.length < 2) return schedule;
  final data = schedule.removeAt(0);
  data.spawnTime = data.spawnTime.add(const Duration(days: 7));
  schedule.add(data);
  if (schedule[1].activatedBosses.isEmpty) {
    schedule.removeAt(1);
  }
  return schedule;
}

WorldBossScheduleSet? reflect(List<WorldBossSchedule> schedule) {
  if (schedule.length < 2) return null;
  return WorldBossScheduleSet(
    previous: schedule.last.toPreviousSchedule(),
    current: schedule.first,
    next: schedule[1],
  );
}

WorldBoss boss(String name) {
  return WorldBoss(
    name: name,
    weekday: 1,
    spawnTime: const TimeOfDay(hour: 0, minute: 0),
    region: BDORegion.KR,
  );
}

WorldBossSchedule makeGroup(DateTime spawnTime, {List<WorldBoss>? bosses}) {
  return WorldBossSchedule(spawnTime: spawnTime, bosses: bosses ?? [boss('x')]);
}

void main() {
  final t0 = DateTime.parse('2026-08-15T00:00:00.000');
  final t1 = t0.add(const Duration(days: 1));
  final t2 = t0.add(const Duration(days: 2));

  group('rotate (schedule 회전)', () {
    test('빈 스케줄은 예외 없이 그대로 반환된다', () {
      final schedule = <WorldBossSchedule>[];
      expect(() => rotate(schedule), returnsNormally);
      expect(rotate(schedule), isEmpty);
    });

    test('그룹이 1개면 회전하지 않고 그대로 반환된다', () {
      final schedule = [makeGroup(t0)];
      final result = rotate(schedule);
      expect(result.length, 1);
      expect(result.first.spawnTime, t0);
    });

    test('그룹이 2개 이상이면 첫 그룹이 +7일 되어 맨 뒤로 이동한다', () {
      final schedule = [makeGroup(t0), makeGroup(t1)];
      final result = rotate(schedule);

      expect(result.length, 2);
      expect(result.first.spawnTime, t1);
      expect(result.last.spawnTime, t0.add(const Duration(days: 7)));
    });

    test('회전 후 새 두 번째 그룹의 activatedBosses가 비어 있으면 제거한다', () {
      // removeAt(0) 후 add로 인덱스가 하나씩 당겨지므로, 회전 뒤 새 인덱스1이 되는 것은
      // 원래 세 번째(t2) 그룹이다.
      final expired = makeGroup(t2, bosses: []); // activatedBosses가 항상 빈 그룹
      final schedule = [makeGroup(t0), makeGroup(t1), expired];

      final result = rotate(schedule);

      expect(result.any((s) => s.spawnTime == t2), isFalse);
      expect(result.length, 2);
      expect(result.first.spawnTime, t1);
      expect(result.last.spawnTime, t0.add(const Duration(days: 7)));
    });
  });

  group('reflect (WorldBossScheduleSet 조립)', () {
    test('그룹이 0개면 null을 반환한다', () {
      expect(reflect([]), isNull);
    });

    test('그룹이 1개면 null을 반환한다', () {
      expect(reflect([makeGroup(t0)]), isNull);
    });

    test('그룹이 2개 이상이면 previous/current/next를 조립한다', () {
      final schedule = [makeGroup(t0), makeGroup(t1), makeGroup(t2)];
      final result = reflect(schedule)!;

      expect(result.current.spawnTime, t0);
      expect(result.next.spawnTime, t1);
      expect(result.previous.spawnTime, t2.subtract(const Duration(days: 7)));
    });
  });
}
