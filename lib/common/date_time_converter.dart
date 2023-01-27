import 'package:flutter/material.dart';
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

  String convertFull(DateTime dateTime){
    return DateFormat('yy.MM.dd HH:mm:ss').format(dateTime);
  }

  String getAmPm(TimeOfDay timeOfDay){
    return timeOfDay.period == DayPeriod.am ? '오전' : '오후';
  }

  String getTime(TimeOfDay timeOfDay){
    return '${timeOfDay.hourOfPeriod}시 ${timeOfDay.minute}분';
  }

  DateTime getDateFromDateTime(DateTime dateTime){
    return DateTime.parse(DateFormat('yyyy-MM-dd').format(dateTime));
  }
  
  String getTimeWithAmPm(TimeOfDay timeOfDay){
    String amPm = getAmPm(timeOfDay);
    String time = getTime(timeOfDay);
    return '$amPm $time';
  }
}
