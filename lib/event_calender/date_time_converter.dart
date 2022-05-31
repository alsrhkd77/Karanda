import 'package:intl/intl.dart';

class DateTimeConverter {
  final List<String> _days = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];

  String dayOfWeek(DateTime dateTime) {
    return _days[dateTime.weekday - 1];
  }

  String simpleMonthDay(DateTime dateTime){
    return DateFormat('MM / dd').format(dateTime);
  }

  String convert(DateTime dateTime){
    return DateFormat('yyyy.MM.dd').format(dateTime);
  }
}
