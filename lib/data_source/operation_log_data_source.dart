import 'dart:convert';

import 'package:karanda/model/operation_log_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OperationLogDataSource {
  static const String _key = 'operation_log';

  Future<List<OperationLogRecord>> load() async {
    final pref = SharedPreferencesAsync();
    final data = await pref.getString(_key);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => OperationLogRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<OperationLogRecord> records) async {
    final pref = SharedPreferencesAsync();
    await pref.setString(_key, jsonEncode(records.map((e) => e.toJson()).toList()));
  }
}
