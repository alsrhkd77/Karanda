import 'package:black_tools/event_calender/custom_calendar.dart';
import 'package:black_tools/event_calender/date_time_converter.dart';
import 'package:black_tools/event_calender/event_calender_controller.dart';
import 'package:black_tools/event_calender/event_data_source.dart';
import 'package:black_tools/widgets/default_app_bar.dart';
import 'package:black_tools/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventCalenderPage extends StatefulWidget {
  const EventCalenderPage({Key? key}) : super(key: key);

  @override
  State<EventCalenderPage> createState() => _EventCalenderPageState();
}

class _EventCalenderPageState extends State<EventCalenderPage> {
  final EventCalenderController _eventCalenderController =
      Get.put(EventCalenderController());
  final DateTimeConverter _dateTimeConverter = DateTimeConverter();
  bool _flag = false;

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
      body: FutureBuilder(
        future: _eventCalenderController.getData(),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return CircularProgressIndicator();
          }
          return SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  ListTile(
                    title: const TitleText(
                      '이벤트 캘린더',
                      bold: true,
                    ),
                    trailing: IconButton(
                      icon: const Icon(FontAwesomeIcons.filter),
                      tooltip: '필터',
                      onPressed: () {},
                    ),
                  ),
                  //Obx(buildCalendar),
                  CustomCalendar(
                    height: (48 * _eventCalenderController.events.length) + 130,
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        tooltip: 'UI 새로고침',
        onPressed: (){
          setState(() {
            _flag = !_flag;
          });
        },
      ),
    );
  }
}
