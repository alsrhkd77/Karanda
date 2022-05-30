import 'package:black_tools/event_calender/event_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<EventModel> list){
    appointments = list;
  }

  @override
  Color getColor(int index) {
    return appointments![index].color;
  }

  @override
  bool isAllDay(int index) {
    return false;
  }

  @override
  String getSubject(int index) {
    print(appointments![index].title);
    return appointments![index].title;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].deadline;
  }

  @override
  DateTime getStartTime(int index) {
    return DateTime.now();
  }


}