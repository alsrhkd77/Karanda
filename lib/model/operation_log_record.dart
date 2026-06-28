import 'package:logging/logging.dart';

class OperationLogRecord {
  final DateTime time;
  final String level;
  final String loggerName;
  final String message;

  const OperationLogRecord({
    required this.time,
    required this.level,
    required this.loggerName,
    required this.message,
  });

  factory OperationLogRecord.fromLogRecord(LogRecord record) {
    return OperationLogRecord(
      time: record.time,
      level: record.level.name,
      loggerName: record.loggerName,
      message: record.error != null
          ? '${record.message}\n${record.error}'
          : record.message,
    );
  }

  factory OperationLogRecord.fromJson(Map<String, dynamic> json) {
    return OperationLogRecord(
      time: DateTime.parse(json['t'] as String),
      level: json['l'] as String,
      loggerName: json['n'] as String,
      message: json['m'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        't': time.toIso8601String(),
        'l': level,
        'n': loggerName,
        'm': message,
      };

  @override
  String toString() =>
      '[${time.toIso8601String()}][$level][$loggerName] $message';
}
