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
    String strHour = hourOfPeriod.toString().padLeft(2, '0');
    String strMinute = minute.toString().padLeft(2, '0');
    if (lang.toUpperCase() == 'KR') {
      return '$strHour시$strMinute분';
    }
    return '$strHour:$strMinute';
  }

  /*
   * return period and time
   * ex) PM 10:15 or 오전 10시13분
   */
  String timeWithPeriod({String period = '', String time = ''}) {
    String strDayPeriod = dayPeriod(lang: period);
    String strTime = timeToString(lang: time);
    return '$strDayPeriod $strTime';
  }
}
