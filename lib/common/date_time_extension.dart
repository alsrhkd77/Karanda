import 'package:intl/intl.dart';

/*
 * DateTime's custom extension
 */
extension DateTimeExtension on DateTime {
  String dOfWeek() {
    final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[weekday - 1];
  }

  String dayOfWeek() {
    final List<String> days = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return days[weekday - 1];
  }

  DateTime toDate() {
    if (isUtc) {
      return DateTime.utc(year, month, day);
    }
    return DateTime(year, month, day);
  }

  String format(String? format) {
    format = format ?? 'yyyy.MM.dd HH:mm:ss';
    return DateFormat(format).format(this);
  }
}
