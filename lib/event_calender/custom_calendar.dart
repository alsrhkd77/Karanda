import 'package:get/get.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/event_calender/event_calender_notifier.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/custom_scroll_behavior.dart';
import '../event_calender/event_model.dart';
import 'package:flutter/material.dart';

class CustomCalendar extends StatefulWidget {
  final List<EventModel>? data;
  final double? height;

  const CustomCalendar({this.height, this.data, Key? key}) : super(key: key);

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  bool openCalendar = false;
  final int maxDays = 61;
  final double eventBarHeight = 45;
  final double cellWidth = 70;

  @override
  void initState() {
    super.initState();
  }

  void open(){
    setState(() {
      openCalendar = !openCalendar;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<EventModel> events = context
        .select<EventCalenderNotifier, List<EventModel>>(
            (value) => value.events)
        .where((element) => element.deadline.isBefore(
            DateTime.now().add(Duration(days: openCalendar ? 999 : 14))))
        .toList();
    return Column(
      children: [
        SizedBox(
          height: (events.length * eventBarHeight) + 85,
          child: ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: CustomScrollView(
              scrollDirection: Axis.horizontal,
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      _CalendarFrame(
                        eventCount: events.length,
                        maxDays: maxDays,
                        eventBarHeight: eventBarHeight,
                        cellWidth: cellWidth,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 82,
                          ),
                          ...events.map((e) => _EventBar(event: e, maxDays: maxDays, height: eventBarHeight, cellWidth: cellWidth,)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton(
            onPressed: open,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(openCalendar ? ' 접기' : ' 펼치기'),
                Icon(openCalendar ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CalendarFrame extends StatelessWidget {
  final int eventCount;
  final int maxDays;
  final double eventBarHeight;
  final double cellWidth;

  const _CalendarFrame({super.key, required this.maxDays, required this.eventBarHeight, required this.cellWidth, required this.eventCount});

  @override
  Widget build(BuildContext context) {
    return Table(
      children: [
        TableRow(
          children: List.generate(maxDays, (index) {
            DateTime date =
            DateTime.now().add(Duration(days: index));
            return TableCell(
              verticalAlignment:
              TableCellVerticalAlignment.bottom,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  children: [
                    (date.day == 1) || (index == 0)
                        ? Card(
                        child: Padding(
                          padding:
                          const EdgeInsets.all(8.0),
                          child: TitleText(
                              '${date.month.toString()}월'),
                        ))
                        : Text(
                      date.dOfWeek(),
                      style: TextStyle(
                        color: date.weekday == 6
                            ? Colors.blue
                            : (date.weekday == 7
                            ? Colors.red
                            : null),
                      ),
                    ),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: date.weekday == 6
                            ? Colors.blue
                            : (date.weekday == 7
                            ? Colors.red
                            : null),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        TableRow(
          children: List.generate(
              maxDays,
                  (index) =>
                  SizedBox(height: (eventCount * eventBarHeight) + 4)),
        )
      ],
      border: TableBorder.symmetric(
          inside:
          BorderSide(color: context.theme.dividerColor)),
      defaultColumnWidth: FixedColumnWidth(cellWidth),
    );
  }
}


class _EventBar extends StatelessWidget {
  final EventModel event;
  final int maxDays;
  final double height;
  final double cellWidth;

  const _EventBar({super.key, required this.event, required this.maxDays, required this.height, required this.cellWidth});

  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw ScaffoldMessengerState().showSnackBar(SnackBar(
        content: Text('해당 링크를 열 수 없습니다. \n $uri '),
        margin: const EdgeInsets.all(24.0),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    int count = int.parse(event.count.split(' ').first);
    if (count > maxDays) count = maxDays;
    return SizedBox(
      width: count * cellWidth,
      height: height,
      child: Card(
        margin: const EdgeInsets.all(6.0),
        color: event.color.withOpacity(0.9),
        surfaceTintColor: event.color,
        shadowColor: event.color,
        elevation: 4.0,
        child: InkWell(
          onTap: () => _launchURL(event.url),
          child: Container(
            padding: const EdgeInsets.all(6.0),
            alignment: Alignment.centerLeft,
            child: Text(
              event.title.split('(최종 수정').first,
              style: const TextStyle(color: Colors.black),
              overflow: TextOverflow.clip,
            ),
          ),
        ),
      ),
    );
  }
}
