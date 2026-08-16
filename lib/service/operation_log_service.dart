import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:karanda/data_source/operation_log_data_source.dart';
import 'package:karanda/model/operation_log_record.dart';
import 'package:karanda/utils/operation_log_throttle.dart';
import 'package:logging/logging.dart';

/// 운영 로그 서비스 — 앱 전역 Logger를 설정하고 로그를 로컬에 저장한다.
///
/// - FINE 이하: debug 모드 콘솔 출력만 (저장 안 함)
/// - INFO 이상: 콘솔 출력 + SharedPreferences 저장
class OperationLogService {
  static const int _maxRecords = 1000;
  static const int _keepDays = 7;
  static const Duration _saveInterval = Duration(seconds: 3);
  static const Duration _cleanupInterval = Duration(hours: 1);

  OperationLogService._();
  static final OperationLogService instance = OperationLogService._();

  final _dataSource = OperationLogDataSource();
  final _throttle = OperationLogThrottle();
  final List<OperationLogRecord> _records = [];
  StreamSubscription<LogRecord>? _logSubscription;
  Timer? _saveTimer;
  Timer? _cleanupTimer;
  bool _dirty = false;

  Future<void> initialize() async {
    hierarchicalLoggingEnabled = true;
    Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
    _logSubscription = Logger.root.onRecord.listen(_onRecord);

    final loaded = await _dataSource.load();
    final cutoff = DateTime.now().subtract(const Duration(days: _keepDays));
    _records.addAll(loaded.where((r) => r.time.isAfter(cutoff)));

    // 정리 후 저장이 필요한 경우만 저장
    if (loaded.length != _records.length) {
      await _dataSource.save(_records);
    }

    _startCleanupTimer();
  }

  void _onRecord(LogRecord record) {
    if (kDebugMode) {
      developer.log(
        record.message,
        time: record.time,
        level: record.level.value,
        name: record.loggerName,
        error: record.error,
        stackTrace: record.stackTrace,
      );
    }

    if (record.level < Level.INFO) return;

    if (!kDebugMode) {
      developer.log(
        record.message,
        time: record.time,
        level: record.level.value,
        name: record.loggerName,
        error: record.error,
        stackTrace: record.stackTrace,
      );
    }

    final message = record.error != null
        ? '${record.message}\n${record.error}'
        : record.message;

    final accepted = _throttle.accept(
      now: record.time,
      level: record.level.name,
      loggerName: record.loggerName,
      message: message,
      build: () => OperationLogRecord.fromLogRecord(record, message: message),
    );

    // 병합·폐기된 경우에도 반복 횟수가 바뀌었을 수 있으므로 저장은 예약한다.
    if (accepted == null) {
      _scheduleSave();
      return;
    }

    // 전역 상한으로 폐기된 로그가 있었다면, 다음으로 통과된 레코드 직전에 요약을 한 번 남긴다.
    final dropped = _throttle.takeDropped();
    if (dropped > 0) {
      _records.add(OperationLogRecord.rateLimit(time: record.time, dropped: dropped));
    }
    _records.add(accepted);

    // 최대 개수 초과 시 오래된 항목 제거
    if (_records.length > _maxRecords) {
      _records.removeRange(0, _records.length - _maxRecords);
    }

    _scheduleSave();
  }

  void _scheduleSave() {
    _dirty = true;
    // 이미 저장이 예약돼 있으면 그대로 둔다. 재시작 디바운스로 두면 고빈도 유입 시
    // 타이머가 계속 재시작돼 저장이 무한히 밀릴 수 있다 — "구간당 1회 저장"으로 상한을 둔다.
    if (_saveTimer?.isActive ?? false) return;
    _saveTimer = Timer(_saveInterval, _flushToStorage);
  }

  Future<void> _flushToStorage() async {
    if (!_dirty) return;
    _dirty = false;
    await _dataSource.save(List.unmodifiable(_records));
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) => _cleanup());
  }

  Future<void> _cleanup() async {
    final cutoff = DateTime.now().subtract(const Duration(days: _keepDays));
    final before = _records.length;
    _records.removeWhere((r) => r.time.isBefore(cutoff));
    if (_records.length != before) {
      await _dataSource.save(List.unmodifiable(_records));
    }
  }

  /// 대기 중인 저장을 즉시 확정한다.
  ///
  /// 저장은 [_saveDebounce]만큼 지연되므로, 프로세스가 곧 종료될 상황(업데이트·앱 종료)에서는
  /// 이 함수를 먼저 await해야 직전 기록이 유실되지 않는다.
  Future<void> flush() async {
    _saveTimer?.cancel();
    await _flushToStorage();
  }

  Future<List<OperationLogRecord>> getRecords() async {
    // 대기 중인 저장이 있으면 먼저 flush
    if (_dirty) {
      _saveTimer?.cancel();
      await _flushToStorage();
    }
    return List.unmodifiable(_records);
  }

  void dispose() {
    _saveTimer?.cancel();
    _cleanupTimer?.cancel();
    _logSubscription?.cancel();
  }
}
