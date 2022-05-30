import 'package:black_tools/event_calender/event_calender_controller.dart';
import 'package:black_tools/widgets/default_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventCalenderPage extends StatefulWidget {
  const EventCalenderPage({Key? key}) : super(key: key);

  @override
  State<EventCalenderPage> createState() => _EventCalenderPageState();
}

class _EventCalenderPageState extends State<EventCalenderPage> {
  final EventCalenderController _eventCalenderController = EventCalenderController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: Center(
        child: Column(
          children: [
            SfCalendar(
              view: CalendarView.month,
              showCurrentTimeIndicator: true,
              showWeekNumber: true,
              showNavigationArrow: true,
              monthViewSettings: MonthViewSettings(
                numberOfWeeksInView: 5,
              ),
              minDate: DateTime.now(),
            ),
            Image.network('https://s1.pearlcdn.com/KR/Upload/thumbnail/2021/H59D2EKOUWEJBQFX20211123205251026.400x225.jpg'),
            Container(
              child: ElevatedButton(
                child: Text('Hello :)'),
                onPressed: (){
                  _eventCalenderController.getData();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
