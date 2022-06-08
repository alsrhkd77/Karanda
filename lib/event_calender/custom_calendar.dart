import '../common/custom_scroll_behavior.dart';
import '../event_calender/date_time_converter.dart';
import '../event_calender/event_calender_controller.dart';
import '../event_calender/event_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CustomCalendar extends StatefulWidget {
  final List<EventModel>? data;
  final double? height;

  const CustomCalendar({this.height, this.data, Key? key}) : super(key: key);

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  final DateTimeConverter _dateTimeConverter = DateTimeConverter();
  int viewDays = 7;

  @override
  void initState() {
    super.initState();
  }

  // build calendar background frame
  Widget buildCalendarFrame() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 90,
      itemBuilder: (context, index) {
        DateTime date = DateTime.now().add(Duration(days: index));
        return Container(
          width: MediaQuery.of(context).size.width / viewDays,
          decoration: BoxDecoration(
              border: Border.symmetric(
            vertical: BorderSide(color: context.theme.dividerColor),
          )),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              (date.day == 1) || (index == 0)
                  ? Text(
                    '${date.month}월',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  )
                  : const SizedBox(
                      height: 28,
                    ),
              Container(
                height: 35,
                alignment: Alignment.bottomCenter,
                child: Text(
                  _dateTimeConverter.dayOfWeek(date),
                  style: TextStyle(
                    color: date.weekday == 6
                        ? Colors.blue
                        : (date.weekday == 7 ? Colors.red : null),
                  ),
                ),
              ),
              const Divider(),
              Text(
                _dateTimeConverter.simpleMonthDay(date),
                style: TextStyle(
                  color: date.weekday == 6
                      ? Colors.blue
                      : (date.weekday == 7 ? Colors.red : null),
                ),
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }

  // build event bar list
  Widget buildEvents() {
    EventCalenderController _controller = Get.find<EventCalenderController>();
    double _eventHeight = widget.height != null
        ? (widget.height! - 120) / 7
        : (Get.height - 120) / 7;
    return SizedBox(
      height: widget.height ?? Get.height,
      width: 90 * (Get.width / viewDays),
      child: Column(
        children: [
          const SizedBox(
            height: 120.0,
          ),
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: _controller.events.length,
              itemBuilder: (context, index) {
                return eventBar(_controller.events[index], _eventHeight);
              })
        ],
      ),
    );
  }

  // single event bar Container
  Widget eventBar(EventModel eventModel, double height) {
    int count = int.parse(eventModel.count.split(' ')[0]);
    if (count > 90) count = 90;
    return Container(
      margin: EdgeInsets.fromLTRB(
          12.0, 4, ((Get.width / viewDays) * (90 - count)) + 12.0, 4),
      child: Tooltip(
        message:
            '${eventModel.title}\n${_dateTimeConverter.convert(eventModel.deadline)} 까지',
        child: InkWell(
          child: Container(
            height: 25,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: eventModel.color,
              borderRadius: BorderRadius.circular(4.0),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              eventModel.title,
              style: TextStyle(fontSize: 12.0),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? Get.height,

      child: Stack(
        children: [
          ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Stack(
                children: [
                  buildCalendarFrame(),
                  Obx(buildEvents),
                ],
              ),
            ),
          ),
          Positioned(
            right: 15.0,
            top: 0.0,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (viewDays > 3) {
                      setState(() {
                        viewDays--;
                      });
                    }
                  },
                  icon: Icon(FontAwesomeIcons.minus),
                ),
                IconButton(
                  icon: Icon(FontAwesomeIcons.plus),
                  onPressed: () {
                    if (viewDays < 14) {
                      setState(() {
                        viewDays++;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
