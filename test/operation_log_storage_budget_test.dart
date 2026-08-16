import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/data_source/operation_log_data_source.dart';
import 'package:karanda/model/operation_log_record.dart';

void main() {
  final base = DateTime.parse('2026-08-15T10:00:00.000');

  OperationLogRecord withStackTrace(int index, int length) {
    return OperationLogRecord(
      time: base.add(Duration(seconds: index)),
      level: 'SEVERE',
      loggerName: 'test',
      message: 'boom $index',
      stackTrace: 'x' * length,
    );
  }

  group('OperationLogDataSource.toJsonList', () {
    test('keeps every stack trace when the total is within budget', () {
      final records = [withStackTrace(0, 100), withStackTrace(1, 100)];

      final list = OperationLogDataSource.toJsonList(records);

      expect(list[0].containsKey('s'), isTrue);
      expect(list[1].containsKey('s'), isTrue);
    });

    test('drops the oldest stack traces first once the budget is exceeded', () {
      const budget = 128 * 1024;
      final records = [
        withStackTrace(0, budget), // 오래된 항목 — 예산을 전부 소비
        withStackTrace(1, 10), // 최신 항목 — 예산 이하
      ];

      final list = OperationLogDataSource.toJsonList(records);

      expect(list[0].containsKey('s'), isFalse, reason: '오래된 항목의 스택트레이스가 먼저 제거되어야 한다');
      expect(list[1].containsKey('s'), isTrue, reason: '최신 항목은 유지되어야 한다');
    });

    test('records without a stack trace do not consume the budget', () {
      final records = [
        OperationLogRecord(
          time: base,
          level: 'INFO',
          loggerName: 'test',
          message: 'no stack trace',
        ),
        withStackTrace(1, 10),
      ];

      final list = OperationLogDataSource.toJsonList(records);

      expect(list[0].containsKey('s'), isFalse);
      expect(list[1].containsKey('s'), isTrue);
    });
  });
}
