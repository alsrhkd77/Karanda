import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:karanda/model/operation_log_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OperationLogDataSource {
  static const String _key = 'operation_log';

  /// 스택트레이스 저장 총량 상한. 반복 SEVERE가 쌓여도 매 저장마다 재직렬화되는
  /// 페이로드가 이 값을 넘지 않게 한다.
  static const int _maxTotalStackTrace = 128 * 1024;

  Future<List<OperationLogRecord>> load() async {
    final pref = SharedPreferencesAsync();
    final data = await pref.getString(_key);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => OperationLogRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 최신 항목부터 스택트레이스 예산을 소진한다. 예산을 넘긴 오래된 항목은 본문만 저장한다.
  /// (메모리 버퍼에는 남아 있으므로 현재 세션 화면·내보내기에는 그대로 보인다.)
  @visibleForTesting
  static List<Map<String, dynamic>> toJsonList(List<OperationLogRecord> records) {
    var budget = _maxTotalStackTrace;
    final result = List<Map<String, dynamic>>.filled(
      records.length,
      const <String, dynamic>{},
      growable: false,
    );
    for (var i = records.length - 1; i >= 0; i--) {
      final length = records[i].stackTrace?.length ?? 0;
      final include = length == 0 || length <= budget;
      if (length > 0 && include) budget -= length;
      result[i] = records[i].toJson(includeStackTrace: include);
    }
    return result;
  }

  Future<void> save(List<OperationLogRecord> records) async {
    final pref = SharedPreferencesAsync();
    await pref.setString(_key, jsonEncode(toJsonList(records)));
  }
}
