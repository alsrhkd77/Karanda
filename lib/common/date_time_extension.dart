import 'package:intl/intl.dart';

/*
 * DateTime's custom extension
 */
extension DateTimeExtension on DateTime {
  String dayOfWeek() {
    final List<String> _days = [
      '월요일',
      '화요일',
      '수요일',
      '목요일',
      '금요일',
      '토요일',
      '일요일'
    ];
    return _days[weekday - 1];
  }

  String format(String? _format) {
    _format = _format ?? 'yyyy.MM.dd HH:mm:ss';
    return DateFormat(_format).format(this);
  }
}
