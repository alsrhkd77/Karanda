import 'package:flutter/foundation.dart';
import 'package:karanda/model/operation_log_record.dart';
import 'package:karanda/service/operation_log_service.dart';

class OperationLogController extends ChangeNotifier {
  final OperationLogService _service;

  List<OperationLogRecord> _records = [];
  bool isLoading = false;

  OperationLogController({OperationLogService? service})
      : _service = service ?? OperationLogService.instance;

  /// UI 표시는 최신 항목이 위로 오도록 역순으로 노출한다.
  List<OperationLogRecord> get records => _records.reversed.toList();

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    _records = await _service.getRecords();
    isLoading = false;
    notifyListeners();
  }
}
