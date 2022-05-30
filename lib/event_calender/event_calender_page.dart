import 'package:black_tools/event_calender/custom_calendar.dart';
import 'package:black_tools/event_calender/event_calender_controller.dart';
import 'package:black_tools/event_calender/event_data_source.dart';
import 'package:black_tools/widgets/default_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventCalenderPage extends StatefulWidget {
  const EventCalenderPage({Key? key}) : super(key: key);

  @override
  State<EventCalenderPage> createState() => _EventCalenderPageState();
}

class _EventCalenderPageState extends State<EventCalenderPage> {
  EventCalenderController _eventCalenderController = EventCalenderController();

  @override
  void initState() {
    _eventCalenderController.getData();
    super.initState();
  }

  Widget buildCalendar() {
    return SizedBox(
      height: 800,
      child: SfCalendar(
        view: CalendarView.month,
        allowAppointmentResize: true,
        monthViewSettings: MonthViewSettings(
          monthCellStyle: MonthCellStyle(
            textStyle: context.theme.textTheme.titleLarge,
          ),
          appointmentDisplayCount: _eventCalenderController.events.length,
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
          numberOfWeeksInView: 1,
        ),
        timeZone: 'Asia/Seoul',
        minDate: DateTime.now(),
        dataSource: EventDataSource(_eventCalenderController.events),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              //Obx(buildCalendar),
              CustomCalendar(
                height: 540,
              ),
              Image.network(
                  'https://s1.pearlcdn.com/KR/Upload/thumbnail/2021/H59D2EKOUWEJBQFX20211123205251026.400x225.jpg'),
              Container(
                child: ElevatedButton(
                  child: Text('Hello :)'),
                  onPressed: () {
                    _eventCalenderController.getData();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
