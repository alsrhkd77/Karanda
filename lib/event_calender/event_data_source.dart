import 'package:black_tools/event_calender/event_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<EventModel> list){
    appointments = list;
  }


}