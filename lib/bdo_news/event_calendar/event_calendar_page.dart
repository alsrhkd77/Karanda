import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/bdo_news/bdo_news_data_controller.dart';
import 'package:karanda/bdo_news/event_calendar/custom_calendar.dart';
import 'package:karanda/bdo_news/models/bdo_event_model.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/common/global_properties.dart';
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
      appBar: const DefaultAppBar(),
      body: StreamBuilder(
        stream: newsDataController.events,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator();
          }
          if(snapshot.requireData.isEmpty){
            return const LoadingIndicator();
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ListTile(
                  title: TitleText(
                    '이벤트 캘린더',
                    bold: true,
                  ),
                  leading: Icon(Icons.celebration_outlined),
                  trailing: MenuAnchor(
                    alignmentOffset: Offset(-80, -10),
                    menuChildren: [
                      MenuItemButton(
                        child: Text('마감일순'),
                        leadingIcon: Icon(FontAwesomeIcons.arrowUpShortWide),
                        onPressed: (){
                          newsDataController.sortEventsByDeadline();
                        },
                      ),
                      MenuItemButton(
                        child: Text('시작일순'),
                        leadingIcon: Icon(FontAwesomeIcons.arrowDownWideShort),
                        onPressed: (){
                          newsDataController.sortEventsByAdded();
                        },
                      ),
                      MenuItemButton(
                        child: Text('무작위'),
                        leadingIcon: Icon(FontAwesomeIcons.shuffle),
                        onPressed: (){
                          newsDataController.shuffleEvents();
                        },
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
                        icon: Icon(FontAwesomeIcons.filter),
                      );
                    },
                  ),
                ),
              ),
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
              SliverToBoxAdapter(
                child: _EventCardList(
                  events: snapshot.requireData,
                ),
              ),
              SliverPadding(padding: GlobalProperties.scrollViewPadding),
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
    double maxWidth = MediaQuery.of(context).size.width;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16.0,
      runSpacing: 16.0,
      children: events
          .map((e) => _EventCard(eventModel: e, maxWidth: maxWidth))
          .toList(),
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
      margin: const EdgeInsets.all(12.0),
      clipBehavior: Clip.antiAlias,
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
