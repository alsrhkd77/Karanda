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

  DateTime date(){
    return DateTime(year, month, day);
  }

  String format(String? str) {
    str = str ?? 'yyyy.MM.dd HH:mm:ss';
    return DateFormat(str).format(this);
  }
}
