import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/model/operation_log_record.dart';
import 'package:karanda/utils/operation_log_throttle.dart';

void main() {
  final base = DateTime.parse('2026-08-15T10:00:00.000');

  OperationLogRecord build(DateTime time, {String message = 'boom'}) {
    return OperationLogRecord(
      time: time,
      level: 'SEVERE',
      loggerName: 'test',
      message: message,
    );
  }

  group('OperationLogThrottle signature suppression', () {
    test('records distinct signatures separately', () {
      final throttle = OperationLogThrottle();
      var calls = 0;

      final a = throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'a',
        message: 'x',
        build: () {
          calls++;
          return build(base);
        },
      );
      final b = throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'b',
        message: 'x',
        build: () {
          calls++;
          return build(base);
        },
      );

      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(calls, 2);
    });

    test('merges a repeat within the window without calling build', () {
      final throttle = OperationLogThrottle(repeatWindow: const Duration(minutes: 1));
      var calls = 0;
      OperationLogRecord makeRecord() {
        calls++;
        return build(base);
      }

      final first = throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'x',
        message: 'boom',
        build: makeRecord,
      )!;

      final second = throttle.accept(
        now: base.add(const Duration(seconds: 10)),
        level: 'SEVERE',
        loggerName: 'x',
        message: 'boom',
        build: makeRecord,
      );

      expect(second, isNull);
      expect(calls, 1);
      expect(first.repeatCount, 2);
      expect(first.time, base);
      expect(first.lastTime, base.add(const Duration(seconds: 10)));
    });

    test('emits a new record once the repeat window has elapsed', () {
      final throttle = OperationLogThrottle(repeatWindow: const Duration(minutes: 1));

      final first = throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'x',
        message: 'boom',
        build: () => build(base),
      )!;

      final second = throttle.accept(
        now: base.add(const Duration(minutes: 2)),
        level: 'SEVERE',
        loggerName: 'x',
        message: 'boom',
        build: () => build(base.add(const Duration(minutes: 2))),
      );

      expect(second, isNotNull);
      expect(first.repeatCount, 1);
    });

    test('treats different levels as different signatures', () {
      final throttle = OperationLogThrottle();
      final a = throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'x',
        message: 'boom',
        build: () => build(base),
      );
      final b = throttle.accept(
        now: base,
        level: 'WARNING',
        loggerName: 'x',
        message: 'boom',
        build: () => build(base),
      );
      expect(a, isNotNull);
      expect(b, isNotNull);
    });

    test('treats different logger names as different signatures', () {
      final throttle = OperationLogThrottle();
      final a = throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'x',
        message: 'boom',
        build: () => build(base),
      );
      final b = throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'y',
        message: 'boom',
        build: () => build(base),
      );
      expect(a, isNotNull);
      expect(b, isNotNull);
    });

    test('treats different messages as different signatures', () {
      final throttle = OperationLogThrottle();
      final a = throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'x',
        message: 'boom',
        build: () => build(base),
      );
      final b = throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'x',
        message: 'bang',
        build: () => build(base),
      );
      expect(a, isNotNull);
      expect(b, isNotNull);
    });
  });

  group('OperationLogThrottle global rate limit', () {
    test('a merged repeat does not consume the global budget', () {
      final throttle = OperationLogThrottle(maxPerSecond: 2);

      for (var i = 0; i < 100; i++) {
        throttle.accept(
          now: base,
          level: 'SEVERE',
          loggerName: 'x',
          message: 'boom',
          build: () => build(base),
        );
      }

      final other = throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'y',
        message: 'boom',
        build: () => build(base),
      );

      expect(other, isNotNull);
    });

    test('drops distinct signatures once the per-second cap is exceeded', () {
      final throttle = OperationLogThrottle(maxPerSecond: 2);

      final a = throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'a',
        message: 'x',
        build: () => build(base),
      );
      final b = throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'b',
        message: 'x',
        build: () => build(base),
      );
      final c = throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'c',
        message: 'x',
        build: () => build(base),
      );

      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(c, isNull);
      expect(throttle.takeDropped(), 1);
    });

    test('resets the budget after the one-second window elapses', () {
      final throttle = OperationLogThrottle(maxPerSecond: 1);

      throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'a',
        message: 'x',
        build: () => build(base),
      );
      final droppedInWindow = throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'b',
        message: 'x',
        build: () => build(base),
      );
      final afterWindow = throttle.accept(
        now: base.add(const Duration(seconds: 1, milliseconds: 1)),
        level: 'SEVERE',
        loggerName: 'c',
        message: 'x',
        build: () => build(base),
      );

      expect(droppedInWindow, isNull);
      expect(afterWindow, isNotNull);
    });

    test('takeDropped resets the counter after reading it', () {
      final throttle = OperationLogThrottle(maxPerSecond: 0);

      throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'a',
        message: 'x',
        build: () => build(base),
      );

      expect(throttle.takeDropped(), 1);
      expect(throttle.takeDropped(), 0);
    });
  });

  group('OperationLogThrottle housekeeping', () {
    test('evicts the oldest tracked signature beyond the capacity', () {
      final throttle = OperationLogThrottle(trackedSignatures: 1, maxPerSecond: 100);

      throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'a',
        message: 'x',
        build: () => build(base),
      );
      throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'b',
        message: 'x',
        build: () => build(base),
      );

      // 'a' 시그니처가 축출되었으므로 다시 오면 병합되지 않고 새 레코드가 된다.
      var calls = 0;
      final record = throttle.accept(
        now: base.add(const Duration(seconds: 1)),
        level: 'SEVERE',
        loggerName: 'a',
        message: 'x',
        build: () {
          calls++;
          return build(base);
        },
      );

      expect(record, isNotNull);
      expect(calls, 1);
    });

    test('does not misbehave when the clock moves backwards', () {
      final throttle = OperationLogThrottle(maxPerSecond: 5);

      final first = throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'x',
        message: 'boom',
        build: () => build(base),
      );

      final earlier = throttle.accept(
        now: base.subtract(const Duration(seconds: 10)),
        level: 'SEVERE',
        loggerName: 'x',
        message: 'boom',
        build: () => build(base),
      );

      expect(first, isNotNull);
      // 시계 역행은 새 창/새 레코드로 취급되어야 하며 무한 억제·무한 폐기로 이어지지 않는다.
      expect(earlier, isNotNull);
    });

    test('clear resets signatures and counters', () {
      final throttle = OperationLogThrottle(maxPerSecond: 1);

      throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'a',
        message: 'x',
        build: () => build(base),
      );
      throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'b',
        message: 'x',
        build: () => build(base),
      );
      expect(throttle.takeDropped(), 1);

      throttle.clear();

      final record = throttle.accept(
        now: base,
        level: 'SEVERE',
        loggerName: 'a',
        message: 'x',
        build: () => build(base),
      );
      expect(record, isNotNull);
      expect(throttle.takeDropped(), 0);
    });
  });
}
