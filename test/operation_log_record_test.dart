import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/model/operation_log_record.dart';
import 'package:logging/logging.dart';

void main() {
  group('OperationLogRecord.fromLogRecord', () {
    test('keeps the stack trace for severe records', () {
      final record = OperationLogRecord.fromLogRecord(
        LogRecord(
          Level.SEVERE,
          'boom',
          'test',
          StateError('bad'),
          StackTrace.fromString('#0 frame'),
        ),
      );

      expect(record.stackTrace, contains('#0 frame'));
      expect(record.message, contains('boom'));
      expect(record.message, contains('bad'));
    });

    test('drops the stack trace below severe to limit storage cost', () {
      final record = OperationLogRecord.fromLogRecord(
        LogRecord(
          Level.WARNING,
          'careful',
          'test',
          StateError('bad'),
          StackTrace.fromString('#0 frame'),
        ),
      );

      expect(record.stackTrace, isNull);
    });

    test('truncates an oversized stack trace', () {
      final record = OperationLogRecord.fromLogRecord(
        LogRecord(
          Level.SEVERE,
          'boom',
          'test',
          StateError('bad'),
          StackTrace.fromString('x' * 10000),
        ),
      );

      expect(record.stackTrace, isNotNull);
      expect(record.stackTrace!.length, lessThan(10000));
      expect(record.stackTrace, endsWith('...(truncated)'));
    });
  });

  group('OperationLogRecord json', () {
    test('reads records saved before the stackTrace field existed', () {
      final legacy = {
        't': '2026-08-02T10:00:00.000',
        'l': 'INFO',
        'n': 'app',
        'm': 'hello',
      };

      final record = OperationLogRecord.fromJson(legacy);

      expect(record.stackTrace, isNull);
      expect(record.message, 'hello');
      expect(record.level, 'INFO');
    });

    test('round-trips a record that carries a stack trace', () {
      final original = OperationLogRecord(
        time: DateTime.parse('2026-08-02T10:00:00.000'),
        level: 'SEVERE',
        loggerName: 'app',
        message: 'boom',
        stackTrace: '#0 frame',
      );

      final restored = OperationLogRecord.fromJson(original.toJson());

      expect(restored.stackTrace, '#0 frame');
      expect(restored.toString(), contains('#0 frame'));
    });

    test('omits the stackTrace key when there is none', () {
      final record = OperationLogRecord(
        time: DateTime.parse('2026-08-02T10:00:00.000'),
        level: 'INFO',
        loggerName: 'app',
        message: 'hello',
      );

      expect(record.toJson().containsKey('s'), isFalse);
    });
  });

  group('OperationLogRecord repeat merging', () {
    test('omits repeat keys when repeatCount is 1 (unchanged legacy payload)', () {
      final record = OperationLogRecord(
        time: DateTime.parse('2026-08-02T10:00:00.000'),
        level: 'INFO',
        loggerName: 'app',
        message: 'hello',
      );

      final json = record.toJson();
      expect(json.containsKey('c'), isFalse);
      expect(json.containsKey('e'), isFalse);
    });

    test('round-trips repeatCount and lastTime', () {
      final original = OperationLogRecord(
        time: DateTime.parse('2026-08-02T10:00:00.000'),
        level: 'SEVERE',
        loggerName: 'app',
        message: 'boom',
      );
      original.markRepeated(DateTime.parse('2026-08-02T10:05:00.000'));

      final restored = OperationLogRecord.fromJson(original.toJson());

      expect(restored.repeatCount, 2);
      expect(restored.lastTime, DateTime.parse('2026-08-02T10:05:00.000'));
    });

    test('legacy json without c/e defaults to repeatCount 1 and lastTime == time', () {
      final legacy = {
        't': '2026-08-02T10:00:00.000',
        'l': 'INFO',
        'n': 'app',
        'm': 'hello',
      };

      final record = OperationLogRecord.fromJson(legacy);

      expect(record.repeatCount, 1);
      expect(record.lastTime, record.time);
    });

    test('markRepeated increments count and updates lastTime but not time', () {
      final record = OperationLogRecord(
        time: DateTime.parse('2026-08-02T10:00:00.000'),
        level: 'SEVERE',
        loggerName: 'app',
        message: 'boom',
      );

      record.markRepeated(DateTime.parse('2026-08-02T10:01:00.000'));
      record.markRepeated(DateTime.parse('2026-08-02T10:02:00.000'));

      expect(record.repeatCount, 3);
      expect(record.lastTime, DateTime.parse('2026-08-02T10:02:00.000'));
      expect(record.time, DateTime.parse('2026-08-02T10:00:00.000'));
    });

    test('toString includes the repeat suffix only when repeated', () {
      final once = OperationLogRecord(
        time: DateTime.parse('2026-08-02T10:00:00.000'),
        level: 'INFO',
        loggerName: 'app',
        message: 'hello',
      );
      expect(once.toString(), isNot(contains('x1')));

      final repeated = OperationLogRecord(
        time: DateTime.parse('2026-08-02T10:00:00.000'),
        level: 'INFO',
        loggerName: 'app',
        message: 'hello',
      )..markRepeated(DateTime.parse('2026-08-02T10:01:00.000'));

      expect(repeated.toString(), contains('x2'));
    });

    test('toJson(includeStackTrace: false) omits the stackTrace key', () {
      final record = OperationLogRecord(
        time: DateTime.parse('2026-08-02T10:00:00.000'),
        level: 'SEVERE',
        loggerName: 'app',
        message: 'boom',
        stackTrace: '#0 frame',
      );

      expect(record.toJson().containsKey('s'), isTrue);
      expect(record.toJson(includeStackTrace: false).containsKey('s'), isFalse);
    });
  });
}
