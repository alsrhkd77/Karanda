import 'package:flutter/material.dart';
import 'package:karanda/bdo_news/models/bdo_event_model.dart';
import 'package:karanda/common/custom_scroll_behavior.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/common/launch_url.dart';
import 'package:karanda/widgets/title_text.dart';

class CustomCalendar extends StatefulWidget {
  final List<BdoEventModel> events;
  final double? height;

  const CustomCalendar({this.height, required this.events, Key? key})
      : super(key: key);

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  final ScrollController _scrollController = ScrollController();
  bool openCalendar = false;
  final int maxDays = 31;
  final double eventBarHeight = 45;
  final double cellWidth = 120;
  int? endingNextWeek;
  int viewItemCount = 0;

  @override
  void initState() {
    var events = widget.events.where((element) {
      Duration diff = element.deadline.difference(DateTime.now());
      if(diff.inDays < 8){
        return true;
      }
      return false;
    });
    if (events.isNotEmpty) {
      endingNextWeek = events.length;
    }
    viewItemCount = endingNextWeek ?? widget.events.length;
    if(viewItemCount < widget.events.length / 3){
      viewItemCount = widget.events.length ~/ 3;
    }
    super.initState();
  }

  void open() {
    setState(() {
      openCalendar = !openCalendar;
      viewItemCount = openCalendar
          ? widget.events.length
          : (endingNextWeek ?? widget.events.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: (viewItemCount * eventBarHeight) + 94,
          child: ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Center(
                  child: Stack(
                    children: [
                      _CalendarFrame(
                        eventCount: viewItemCount,
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
                          ...widget.events
                              .take(viewItemCount)
                              .map((e) {
                            return _EventBar(
                              event: e,
                              maxDays: maxDays,
                              height: eventBarHeight,
                              cellWidth: cellWidth,
                            );
                          }),
                          //...events.map((e) => _EventBar(event: e, maxDays: maxDays, height: eventBarHeight, cellWidth: cellWidth,)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
          child: ElevatedButton(
            onPressed: open,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(openCalendar ? ' 접기' : ' 펼치기'),
                Icon(openCalendar
                    ? Icons.keyboard_double_arrow_up
                    : Icons.keyboard_double_arrow_down),
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

  const _CalendarFrame(
      {super.key,
      required this.maxDays,
      required this.eventBarHeight,
      required this.cellWidth,
      required this.eventCount});

  @override
  Widget build(BuildContext context) {
    return Table(
      children: [
        TableRow(
          children: List.generate(maxDays, (index) {
            DateTime date = DateTime.now().add(Duration(days: index));
            return TableCell(
              verticalAlignment: TableCellVerticalAlignment.bottom,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  children: [
                    (date.day == 1) || (index == 0)
                        ? Card(
                            child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TitleText('${date.month.toString()}월'),
                          ))
                        : Text(
                            date.dOfWeek(),
                            style: TextStyle(
                              color: date.weekday == 6
                                  ? Colors.blue
                                  : (date.weekday == 7 ? Colors.red : null),
                            ),
                          ),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: date.weekday == 6
                            ? Colors.blue
                            : (date.weekday == 7 ? Colors.red : null),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        TableRow(
          children: List.generate(maxDays,
              (index) => SizedBox(height: (eventCount * eventBarHeight) + 4)),
        )
      ],
      border: TableBorder.symmetric(
          inside: BorderSide(color: Theme.of(context).dividerColor)),
      defaultColumnWidth: FixedColumnWidth(cellWidth),
    );
  }
}

class _EventBar extends StatelessWidget {
  final BdoEventModel event;
  final int maxDays;
  final double height;
  final double cellWidth;

  const _EventBar(
      {super.key,
      required this.event,
      required this.maxDays,
      required this.height,
      required this.cellWidth});

  @override
  Widget build(BuildContext context) {
    int count = event.countToInt() + 1;
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
          onTap: () => launchURL(event.url),
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
