import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:karanda/common/file_saver/file_saver.dart';
import 'package:karanda/model/operation_log_record.dart';
import 'package:karanda/service/operation_log_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class OperationLogController extends ChangeNotifier {
  final OperationLogService _service;

  List<OperationLogRecord> _records = [];
  bool isLoading = false;

  OperationLogController({OperationLogService? service})
      : _service = service ?? OperationLogService.instance;

  /// UI 표시는 최신 항목이 위로 오도록 역순으로 노출한다.
  List<OperationLogRecord> get records => _records.reversed.toList();

  bool get isEmpty => _records.isEmpty;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    _records = await _service.getRecords();
    isLoading = false;
    notifyListeners();
  }

  /// 문의에 첨부할 텍스트를 만든다.
  ///
  /// 화면과 달리 시간순(오래된 것부터)으로 나열한다. 장애를 추적할 때는 발생 순서가 중요하다.
  /// 머리말의 앱 버전·플랫폼은 로그만으로는 알 수 없어 문의 응대에 매번 되묻게 되는 정보다.
  Future<String> buildExportText({String? locale}) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final buffer = StringBuffer()
      ..writeln('# Karanda operation log')
      ..writeln('exported: ${DateTime.now().toIso8601String()}')
      ..writeln('version : ${packageInfo.version}+${packageInfo.buildNumber}')
      ..writeln('platform: ${_platformName()}');
    if (locale != null) {
      buffer.writeln('locale  : $locale');
    }
    final events = _records.fold<int>(0, (sum, r) => sum + r.repeatCount);
    buffer
      ..writeln('records : ${_records.length}')
      ..writeln('events  : $events')
      ..writeln();

    for (final record in _records) {
      buffer.writeln(record.toString());
    }
    return buffer.toString();
  }

  String _platformName() {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform.name;
  }

  /// 텍스트 파일로 내보낸다. 플랫폼별 동작 차이는 [FileSaveResult]를 참고.
  Future<FileSaveResult> exportToFile({String? locale}) async {
    final text = await buildExportText(locale: locale);
    return FileSaver().saveBytes(
      Uint8List.fromList(utf8.encode(text)),
      _fileName(),
    );
  }

  Future<void> copyToClipboard({String? locale}) async {
    final text = await buildExportText(locale: locale);
    await Clipboard.setData(ClipboardData(text: text));
  }

  String _fileName() {
    final stamp = DateFormat('yyyyMMdd-HHmmss').format(DateTime.now());
    return 'karanda-operation-log-$stamp.txt';
  }
}
