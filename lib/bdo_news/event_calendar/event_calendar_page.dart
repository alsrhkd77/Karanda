import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/bdo_news/bdo_news_data_controller.dart';
import 'package:karanda/bdo_news/event_calendar/custom_calendar.dart';
import 'package:karanda/bdo_news/models/bdo_event_model.dart';
import 'package:karanda/bdo_news/widgets/deadline_tag_chip.dart';
import 'package:karanda/bdo_news/widgets/new_tag_chip.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/common/launch_url.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/title_text.dart';

class EventCalendarPage extends StatefulWidget {
  const EventCalendarPage({super.key});

  @override
  State<EventCalendarPage> createState() => _EventCalendarPageState();
}

class _EventCalendarPageState extends State<EventCalendarPage> {
  final BdoNewsDataController newsDataController = BdoNewsDataController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => newsDataController.subscribeEvents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: '이벤트 캘린더',
        icon: Icons.celebration_outlined,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: MenuAnchor(
              menuChildren: [
                MenuItemButton(
                  onPressed: () {
                    newsDataController.sortEventsByDeadline();
                  },
                  leadingIcon: const Icon(FontAwesomeIcons.arrowUpShortWide),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('마감일순'),
                  ),
                ),
                MenuItemButton(
                  onPressed: () {
                    newsDataController.sortEventsByAdded();
                  },
                  leadingIcon: const Icon(FontAwesomeIcons.arrowDownWideShort),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('시작일순'),
                  ),
                ),
                MenuItemButton(
                  onPressed: () {
                    newsDataController.shuffleEvents();
                  },
                  leadingIcon: const Icon(FontAwesomeIcons.shuffle),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('무작위'),
                  ),
                ),
              ],
              builder: (BuildContext context, MenuController controller,
                  Widget? child) {
                return IconButton(
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  icon: const Icon(FontAwesomeIcons.filter),
                );
              },
            ),
          )
        ],
      ),
      body: StreamBuilder(
        stream: newsDataController.events,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator();
          }
          if (snapshot.requireData.isEmpty) {
            return const LoadingIndicator();
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: CustomCalendar(
                  events: snapshot.requireData,
                ),
              ),
              const SliverToBoxAdapter(
                child: Divider(),
              ),
              const SliverToBoxAdapter(
                child: ListTile(
                  title: TitleText('이벤트 바로가기'),
                ),
              ),
              _EventCardList(
                events: snapshot.requireData,
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 25.0)),
            ],
          );
        },
      ),
    );
  }
}

class _EventCardList extends StatelessWidget {
  final List<BdoEventModel> events;

  const _EventCardList({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    int count = max(1, width ~/ 380);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      sliver: SliverGrid.count(
        crossAxisCount: count,
        childAspectRatio: 1.77,
        mainAxisSpacing: 24.0,
        crossAxisSpacing: 24.0,
        children: events
            .map((e) => _EventCard(eventModel: e, maxWidth: width))
            .toList(),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final BdoEventModel eventModel;
  final double maxWidth;

  const _EventCard(
      {super.key, required this.eventModel, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      child: InkWell(
        onTap: () => launchURL(eventModel.url),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              eventModel.thumbnail,
              fit: BoxFit.fill,
            ),
            Positioned(
              right: 10,
              top: 8,
              child: eventModel.nearDeadline
                  ? DeadlineTagChip(
                      count: eventModel.countToInt(),
                    )
                  : (eventModel.newTag ? const NewTagChip() : Container()),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8.0, 12.0, 12.0, 4.0),
                color: Colors.black.withOpacity(0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      eventModel.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
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
