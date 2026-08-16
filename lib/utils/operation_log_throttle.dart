import 'package:karanda/model/operation_log_record.dart';

/// 운영 로그 유입 억제기 — 반복 예외가 저장 버퍼와 디스크를 잠식하는 것을 막는다.
///
/// 두 단계로 판정한다.
/// 1) 시그니처(level+loggerName+message) 억제: [repeatWindow] 안에 같은 시그니처가 다시 오면
///    새 레코드를 만들지 않고 기존 레코드의 반복 횟수만 올린다. 이 병합은 전역 예산을 소비하지 않는다.
/// 2) 전역 초당 상한: 시그니처와 무관하게 1초에 [maxPerSecond]건까지만 새 레코드를 만든다.
///
/// 시각을 인자로 받고 Timer·저장소를 쓰지 않으므로 순수 단위 테스트가 가능하다.
class OperationLogThrottle {
  OperationLogThrottle({
    this.maxPerSecond = 20,
    this.repeatWindow = const Duration(minutes: 1),
    this.trackedSignatures = 32,
  });

  final int maxPerSecond;
  final Duration repeatWindow;
  final int trackedSignatures;

  /// 시그니처 → 마지막으로 병합된 레코드. 삽입 순서를 LRU 축출 기준으로 쓴다.
  final Map<String, OperationLogRecord> _signatures = {};

  DateTime? _windowStart;
  int _windowCount = 0;
  int _dropped = 0;

  /// 기록 여부를 판정한다.
  ///
  /// 반환값이 null이면 버퍼에 추가하지 않는다(반복 병합 또는 상한 초과로 폐기).
  /// [build]는 기록이 확정된 경우에만 호출되므로, 스택트레이스 문자열화 같은 비싼 작업이
  /// 억제된 로그에서는 수행되지 않는다.
  OperationLogRecord? accept({
    required DateTime now,
    required String level,
    required String loggerName,
    required String message,
    required OperationLogRecord Function() build,
  }) {
    final key = '$level|$loggerName|$message';

    final last = _signatures[key];
    if (last != null) {
      final withinWindow =
          !now.isBefore(last.lastTime) && now.difference(last.lastTime) < repeatWindow;
      if (withinWindow) {
        last.markRepeated(now);
        return null;
      }
      _signatures.remove(key);
    }

    final start = _windowStart;
    if (start == null || now.isBefore(start) || now.difference(start) >= const Duration(seconds: 1)) {
      _windowStart = now;
      _windowCount = 0;
    }
    if (_windowCount >= maxPerSecond) {
      _dropped++;
      return null;
    }
    _windowCount++;

    final record = build();
    _signatures[key] = record;
    if (_signatures.length > trackedSignatures) {
      _signatures.remove(_signatures.keys.first);
    }
    return record;
  }

  /// 전역 상한으로 버려진 건수를 반환하고 0으로 초기화한다.
  int takeDropped() {
    final value = _dropped;
    _dropped = 0;
    return value;
  }

  /// 시그니처 테이블과 상한 창을 비운다.
  void clear() {
    _signatures.clear();
    _windowStart = null;
    _windowCount = 0;
    _dropped = 0;
  }
}
