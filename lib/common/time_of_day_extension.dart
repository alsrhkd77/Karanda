import 'package:flutter/material.dart';

/*
 * TimeOfDay's custom extension
 */
extension TimeOfDayExtension on TimeOfDay {
  /* get AM/PM */
  String dayPeriod({String lang = ''}) {
    if (lang.toUpperCase() == 'KR') {
      return period == DayPeriod.am ? '오전' : '오후';
    }
    return period == DayPeriod.am ? 'AM' : 'PM';
  }

  /*
  * return time to string
  * ex) 00:00 or 00시00분
  */
  String timeToString({String lang = ''}) {
    String _hour = hourOfPeriod.toString().padLeft(2, '0');
    String _minute = minute.toString().padLeft(2, '0');
    if (lang.toUpperCase() == 'KR') {
      return '$_hour시$_minute분';
    }
    return '$_hour:$_minute';
  }

  /*
   * return period and time
   * ex) PM 17:15 or 오전 10시13분
   */
  String timeWithPeriod({String period = '', String time = ''}) {
    String _dayPeriod = dayPeriod(lang: period);
    String _time = timeToString(lang: time);
    return '$_dayPeriod $_time';
  }
}
