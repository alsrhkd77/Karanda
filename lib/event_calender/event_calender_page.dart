import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/event_calender/event_calender_notifier.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../event_calender/custom_calendar.dart';
import '../event_calender/event_model.dart';
import '../widgets/default_app_bar.dart';
import '../widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class EventCalenderPage extends StatefulWidget {
  const EventCalenderPage({Key? key}) : super(key: key);

  @override
  State<EventCalenderPage> createState() => _EventCalenderPageState();
}

class _EventCalenderPageState extends State<EventCalenderPage> {
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
        body: ChangeNotifierProvider(
          create: (_) => EventCalenderNotifier(),
          child: Consumer<EventCalenderNotifier>(
            builder: (_, notifier, __) {
              if (notifier.events.isEmpty) {
                return const LoadingIndicator();
              }
              return ListView(
                children: [
                  ListTile(
                    title: const TitleText(
                      '이벤트 캘린더',
                      bold: true,
                    ),
                    subtitle: Text('최근 갱신: ${notifier.lastUpdate}'),
                    leading: const Icon(FontAwesomeIcons.calendarCheck),
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
                        const PopupMenuDivider(),
                        popupMenuItem('7일 이내', FontAwesomeIcons.calendarWeek),
                        popupMenuItem('30일 이내', FontAwesomeIcons.calendar),
                        popupMenuItem('전체', FontAwesomeIcons.infinity),
                      ],
                    ),
                  ),
                  CustomCalendar(
                    height: (33 * notifier.events.length) + 130,
                  ),
                  const Divider(),
                  const ListTile(
                    title: TitleText('이벤트 바로가기'),
                  ),
                  const _EventCardList(),
                ],
              );
            },
          ),
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
    return Card(
      margin: const EdgeInsets.all(12.0),
      clipBehavior: Clip.antiAlias,
      shadowColor: eventModel.color,
      elevation: 4.0,
      child: InkWell(
        //onTap: () => _launchURL(eventModel.url),
        onTap: () => _launchURL(eventModel.url),
        child: Stack(
          //clipBehavior: Clip.hardEdge,
          children: [
            Image.network(
              eventModel.thumbnail,
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 0,
              left: -12,
              child: Container(
                width: 412,
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
