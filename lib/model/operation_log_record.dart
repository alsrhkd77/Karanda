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

  /// 동일 시그니처(level+loggerName+message)가 반복돼 [OperationLogThrottle]이 병합한 횟수.
  /// 1이면 반복 없음.
  int repeatCount;

  /// 마지막으로 반복이 관측된 시각. 반복이 없으면 [time]과 같다.
  DateTime lastTime;

  OperationLogRecord({
    required this.time,
    required this.level,
    required this.loggerName,
    required this.message,
    this.stackTrace,
    this.repeatCount = 1,
    DateTime? lastTime,
  }) : lastTime = lastTime ?? time;

  factory OperationLogRecord.fromLogRecord(LogRecord record, {String? message}) {
    return OperationLogRecord(
      time: record.time,
      level: record.level.name,
      loggerName: record.loggerName,
      message: message ??
          (record.error != null
              ? '${record.message}\n${record.error}'
              : record.message),
      stackTrace: _stackTraceOf(record),
    );
  }

  /// 전역 초당 상한(`OperationLogThrottle`)으로 로그가 버려졌음을 알리는 합성 레코드.
  factory OperationLogRecord.rateLimit({
    required DateTime time,
    required int dropped,
  }) {
    return OperationLogRecord(
      time: time,
      level: 'WARNING',
      loggerName: 'operation_log',
      message: 'Operation log rate limit exceeded, $dropped records dropped',
    );
  }

  /// 동일 시그니처 반복 관측. 새 레코드를 만들지 않고 횟수·마지막 시각만 갱신한다.
  void markRepeated(DateTime at) {
    repeatCount++;
    lastTime = at;
  }

  static String? _stackTraceOf(LogRecord record) {
    if (record.stackTrace == null) return null;
    if (record.level < Level.SEVERE) return null;
    final text = record.stackTrace.toString();
    return text.length > _maxStackTraceLength
        ? '${text.substring(0, _maxStackTraceLength)}\n...(truncated)'
        : text;
  }

  /// 이전 버전은 `s`/`c`/`e` 키 없이 저장했으므로 누락을 허용한다.
  factory OperationLogRecord.fromJson(Map<String, dynamic> json) {
    final time = DateTime.parse(json['t'] as String);
    return OperationLogRecord(
      time: time,
      level: json['l'] as String,
      loggerName: json['n'] as String,
      message: json['m'] as String,
      stackTrace: json['s'] as String?,
      repeatCount: json['c'] as int? ?? 1,
      lastTime: json['e'] != null ? DateTime.parse(json['e'] as String) : time,
    );
  }

  /// [includeStackTrace]가 false면 스택트레이스를 생략한다.
  /// (`OperationLogDataSource`가 저장 총량 상한을 넘긴 오래된 레코드에 사용한다.)
  Map<String, dynamic> toJson({bool includeStackTrace = true}) => {
        't': time.toIso8601String(),
        'l': level,
        'n': loggerName,
        'm': message,
        if (includeStackTrace && stackTrace != null) 's': stackTrace,
        if (repeatCount > 1) 'c': repeatCount,
        if (repeatCount > 1) 'e': lastTime.toIso8601String(),
      };

  @override
  String toString() {
    final head = '[${time.toIso8601String()}][$level][$loggerName] $message';
    final repeated =
        repeatCount > 1 ? '$head (x$repeatCount, last ${lastTime.toIso8601String()})' : head;
    return stackTrace == null ? repeated : '$repeated\n$stackTrace';
  }
}
