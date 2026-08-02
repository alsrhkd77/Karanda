import 'package:logging/logging.dart';

class OperationLogRecord {
  /// 스택트레이스 저장 상한. 저장소 비용을 억제하기 위해 이 길이에서 잘라낸다.
  static const int _maxStackTraceLength = 4000;

  final DateTime time;
  final String level;
  final String loggerName;
  final String message;

  /// 원인 추적용 스택트레이스. `severe`/`shout`에만 저장되며 그 외에는 null이다.
  ///
  /// 모든 레벨에 저장하지 않는 이유: `OperationLogDataSource`가 전체 레코드를
  /// SharedPreferences의 단일 JSON 문자열로 직렬화하고, 로그가 쌓일 때마다 전량을
  /// 다시 직렬화한다. 저빈도·고가치인 심각 오류에만 붙여 비용을 제한한다.
  final String? stackTrace;

  const OperationLogRecord({
    required this.time,
    required this.level,
    required this.loggerName,
    required this.message,
    this.stackTrace,
  });

  factory OperationLogRecord.fromLogRecord(LogRecord record) {
    return OperationLogRecord(
      time: record.time,
      level: record.level.name,
      loggerName: record.loggerName,
      message: record.error != null
          ? '${record.message}\n${record.error}'
          : record.message,
      stackTrace: _stackTraceOf(record),
    );
  }

  static String? _stackTraceOf(LogRecord record) {
    if (record.stackTrace == null) return null;
    if (record.level < Level.SEVERE) return null;
    final text = record.stackTrace.toString();
    return text.length > _maxStackTraceLength
        ? '${text.substring(0, _maxStackTraceLength)}\n...(truncated)'
        : text;
  }

  /// 이전 버전은 `s` 키 없이 저장했으므로 누락을 허용한다.
  factory OperationLogRecord.fromJson(Map<String, dynamic> json) {
    return OperationLogRecord(
      time: DateTime.parse(json['t'] as String),
      level: json['l'] as String,
      loggerName: json['n'] as String,
      message: json['m'] as String,
      stackTrace: json['s'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        't': time.toIso8601String(),
        'l': level,
        'n': loggerName,
        'm': message,
        if (stackTrace != null) 's': stackTrace,
      };

  @override
  String toString() {
    final head = '[${time.toIso8601String()}][$level][$loggerName] $message';
    return stackTrace == null ? head : '$head\n$stackTrace';
  }
}
