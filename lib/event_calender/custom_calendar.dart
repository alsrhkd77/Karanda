import 'package:black_tools/common/custom_scroll_behavior.dart';
import 'package:black_tools/event_calender/date_time_converter.dart';
import 'package:black_tools/event_calender/event_calender_controller.dart';
import 'package:black_tools/event_calender/event_model.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
  }

  Widget buildCalendarFrame() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 90,
      itemBuilder: (context, index) {
        DateTime date = DateTime.now().add(Duration(days: index));
        return Container(
          width: MediaQuery.of(context).size.width / 7,
          decoration: BoxDecoration(
              border: Border.symmetric(
                  vertical: BorderSide(color: context.theme.dividerColor))),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              (date.day == 1) || (index == 0)
                  ? Container(
                      child: Text(
                        '${date.month}월',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    )
                  : const SizedBox(
                      height: 29,
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

  Widget buildEvents() {
    EventCalenderController _controller = Get.find<EventCalenderController>();
    double _eventHeight = widget.height != null
        ? (widget.height! - 120) / 7
        : (Get.height - 120) / 7;
    return SizedBox(
      height: widget.height ?? Get.height,
      width: 90 * (Get.width / 7),
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

  Widget eventBar(EventModel eventModel, double height) {
    int count = int.parse(eventModel.count.split(' ')[0]) + 1;
    if(count > 90) count = 90;
    return Container(
      margin: EdgeInsets.fromLTRB(12.0, 4, ((Get.width / 7) * (90 - count)) + 12.0, 4),
      child: Tooltip(
        message: '${eventModel.title}\n${_dateTimeConverter.convert(eventModel.deadline)} 까지',
        child: InkWell(
          child: Container(
            height: 40,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: eventModel.color,
              borderRadius: BorderRadius.circular(4.0),
            ),
            alignment: Alignment.centerLeft,
            child: Text(eventModel.title),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? Get.height,
      width: Get.width,
      child: ScrollConfiguration(
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
    );
  }
}
