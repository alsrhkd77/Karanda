import 'package:karanda/common/date_time_extension.dart';

import '../event_calender/custom_calendar.dart';
import '../event_calender/event_calender_controller.dart';
import '../event_calender/event_model.dart';
import '../widgets/default_app_bar.dart';
import '../widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class EventCalenderPage extends StatefulWidget {
  const EventCalenderPage({Key? key}) : super(key: key);

  @override
  State<EventCalenderPage> createState() => _EventCalenderPageState();
}

class _EventCalenderPageState extends State<EventCalenderPage> {
  final EventCalenderController _eventCalenderController =
      Get.put(EventCalenderController());

  @override
  void initState() {
    super.initState();
  }

  PopupMenuItem buildPopUpMenuItem(String name, IconData icon) {
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

  Widget buildEventCard() {
    if (_eventCalenderController.allEvents.isEmpty) {
      return const SizedBox();
    }
    double maxWidth = MediaQuery.of(context).size.width;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16.0,
      runSpacing: 16.0,
      children: _eventCalenderController.allEvents
          .map((e) => eventCard(e, maxWidth))
          .toList(),
    );
  }

  Widget eventCard(EventModel eventModel, double maxWidth) {
    return Card(
      margin: const EdgeInsets.all(12.0),
      clipBehavior: Clip.antiAlias,
      shadowColor: eventModel.color,
      elevation: 8.0,
      child: InkWell(
        onTap: () => _launchURL(eventModel.url),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Image.network(
              eventModel.thumbnail,
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.lighten,
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
                        eventModel.count == '상시'
                            ? const SizedBox()
                            : Text(
                                '${eventModel.deadline.format('yyyy.MM.dd')}까지',
                                style: const TextStyle(color: Colors.white),
                              ),
                        Text(
                          eventModel.count,
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

  Widget eventCardOld(EventModel eventModel) {
    return Card(
      margin: const EdgeInsets.all(12.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _launchURL(eventModel.url),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 150,
              color: eventModel.color,
            ),
            SizedBox(
              height: 150,
              width: 150,
              child: Image.network(
                eventModel.thumbnail,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: 310,
              height: 150,
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventModel.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.0),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Text(
                    eventModel.meta.length > 180
                        ? eventModel.meta.substring(0, 180)
                        : eventModel.meta,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: const TextStyle(fontSize: 12.0),
                    maxLines: 3,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      eventModel.count == '상시'
                          ? const SizedBox()
                          : Text(
                              '${eventModel.deadline.format('yyyy.MM.dd')}까지'),
                      Text(eventModel.count),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Get.snackbar('Failed', '해당 링크를 열 수 없습니다. \n $uri ',
          margin: const EdgeInsets.all(24.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: FutureBuilder(
        future: _eventCalenderController.getData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: SpinKitFadingCube(
                size: 120.0,
                color: Colors.blue,
              ),
            );
          }
          return ListView(
            children: [
              ListTile(
                title: const TitleText(
                  '이벤트 캘린더',
                  bold: true,
                ),
                subtitle: Obx(() =>
                    Text('최근 갱신: ${_eventCalenderController.lastUpdate}')),
                leading: const Icon(FontAwesomeIcons.calendarCheck),
                trailing: PopupMenuButton(
                  icon: const Icon(FontAwesomeIcons.filter),
                  tooltip: 'Filter',
                  onSelected: (value) {
                    _eventCalenderController.setFilter(value);
                    setState(() {});
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    buildPopUpMenuItem(
                        '오름차순', FontAwesomeIcons.arrowUpShortWide),
                    buildPopUpMenuItem(
                        '내림차순', FontAwesomeIcons.arrowDownWideShort),
                    buildPopUpMenuItem('무작위', FontAwesomeIcons.shuffle),
                    const PopupMenuDivider(),
                    buildPopUpMenuItem('7일 이내', FontAwesomeIcons.calendarWeek),
                    buildPopUpMenuItem('30일 이내', FontAwesomeIcons.calendar),
                    buildPopUpMenuItem('전체', FontAwesomeIcons.infinity),
                  ],
                ),
              ),
              CustomCalendar(
                height: (33 * _eventCalenderController.events.length) + 130,
              ),
              const Divider(),
              const ListTile(
                title: TitleText('이벤트 바로가기'),
              ),
              Center(child: Obx(buildEventCard)),
            ],
          );
        },
      ),
    );
  }
}
