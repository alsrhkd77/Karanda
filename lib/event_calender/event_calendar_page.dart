import 'dart:math';

import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/common/launch_url.dart';
import 'package:karanda/event_calender/event_calender_notifier.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../event_calender/custom_calendar.dart';
import '../event_calender/event_model.dart';
import '../widgets/default_app_bar.dart';
import '../widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EventCalendarPage extends StatefulWidget {
  const EventCalendarPage({Key? key}) : super(key: key);

  @override
  State<EventCalendarPage> createState() => _EventCalendarPageState();
}

class _EventCalendarPageState extends State<EventCalendarPage> {
  @override
  void initState() {
    super.initState();
  }

  PopupMenuItem popupMenuItem(String name, IconData icon) {
    return PopupMenuItem(
      value: name,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(
            width: 10.0,
          ),
          Text(name),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const DefaultAppBar(),
        body: Consumer<EventCalenderNotifier>(
          builder: (_, notifier, __) {
            if (notifier.events.isEmpty) {
              return const LoadingIndicator();
            }
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ListTile(
                    title: const TitleText(
                      '이벤트 캘린더',
                      bold: true,
                    ),
                    //subtitle: Text('최근 갱신: ${notifier.lastUpdate}'),
                    leading: const Icon(Icons.celebration_outlined),
                    trailing: PopupMenuButton(
                      icon: const Icon(FontAwesomeIcons.filter),
                      tooltip: 'Filter',
                      onSelected: (value) => notifier.setFilter(value),
                      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                        popupMenuItem(
                            '오름차순', FontAwesomeIcons.arrowUpShortWide),
                        popupMenuItem(
                            '내림차순', FontAwesomeIcons.arrowDownWideShort),
                        popupMenuItem('무작위', FontAwesomeIcons.shuffle),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: CustomCalendar(),
                ),
                const SliverToBoxAdapter(
                  child: Divider(),
                ),
                const SliverToBoxAdapter(
                  child: ListTile(
                    title: TitleText('이벤트 바로가기'),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: _EventCardList(),
                ),
                SliverPadding(padding: GlobalProperties.scrollViewPadding),
              ],
            );
          },
        ));
  }
}

class _EventCardList extends StatelessWidget {
  const _EventCardList({super.key});

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16.0,
      runSpacing: 16.0,
      children: context
          .watch<EventCalenderNotifier>()
          .allEvents
          .map((e) => _EventCard(eventModel: e, maxWidth: maxWidth))
          .toList(),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel eventModel;
  final double maxWidth;

  const _EventCard(
      {super.key, required this.eventModel, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12.0),
      clipBehavior: Clip.antiAlias,
      //shadowColor: eventModel.color,
      elevation: 4.0,
      child: InkWell(
        onTap: () => launchURL(eventModel.url),
        child: Stack(
          //clipBehavior: Clip.hardEdge,
          children: [
            Image.network(
              eventModel.thumbnail,
              fit: BoxFit.cover,
              width: min(maxWidth, 380),
            ),
            Positioned(
              bottom: 0,
              left: -12,
              child: Container(
                width: 392,
                constraints: BoxConstraints(
                  maxWidth: maxWidth - 12,
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
                color: Colors.black.withOpacity(0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eventModel.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 6.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          eventModel.count,
                          style: const TextStyle(color: Colors.white),
                        ),
                        eventModel.count == '상시'
                            ? const SizedBox()
                            : Text(
                                '${eventModel.deadline.format('yy.MM.dd')} 까지',
                                style: const TextStyle(color: Colors.white),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
