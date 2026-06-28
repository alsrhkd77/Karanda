import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:karanda/data_source/operation_log_data_source.dart';
import 'package:karanda/model/operation_log_record.dart';
import 'package:logging/logging.dart';

/// 운영 로그 서비스 — 앱 전역 Logger를 설정하고 로그를 로컬에 저장한다.
///
/// - FINE 이하: debug 모드 콘솔 출력만 (저장 안 함)
/// - INFO 이상: 콘솔 출력 + SharedPreferences 저장
class OperationLogService {
  static const int _maxRecords = 1000;
  static const int _keepDays = 7;
  static const Duration _saveDebounce = Duration(milliseconds: 500);
  static const Duration _cleanupInterval = Duration(hours: 1);

  OperationLogService._();
  static final OperationLogService instance = OperationLogService._();

  final _dataSource = OperationLogDataSource();
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

    _records.add(OperationLogRecord.fromLogRecord(record));

    // 최대 개수 초과 시 오래된 항목 제거
    if (_records.length > _maxRecords) {
      _records.removeRange(0, _records.length - _maxRecords);
    }

    _scheduleSave();
  }

  void _scheduleSave() {
    _dirty = true;
    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDebounce, _flushToStorage);
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
