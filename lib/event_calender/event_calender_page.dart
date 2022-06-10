import '../event_calender/custom_calendar.dart';
import '../common/date_time_converter.dart';
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
  final DateTimeConverter _dateTimeConverter = DateTimeConverter();
  bool _flag = false;

  @override
  void initState() {
    super.initState();
  }

  Widget buildEventCard() {
    if (_eventCalenderController.allEvents.isEmpty) {
      return SizedBox();
    }
    List<Widget> list = [];
    for (EventModel eventModel in _eventCalenderController.allEvents) {
      Widget card = eventCard(eventModel);
      list.add(card);
    }
    return Wrap(
      spacing: 18.0,
      runSpacing: 18.0,
      children: list,
    );
  }

  Widget eventCard(EventModel eventModel) {
    return Card(
      margin: const EdgeInsets.all(12.0),
      clipBehavior: Clip.antiAlias,
      child: Tooltip(
        message: eventModel.url,
        child: InkWell(
          onTap: () => _launchURL(eventModel.url),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 15,
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
                padding: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eventModel.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                      overflow: TextOverflow.visible,
                    ),
                    Text(
                      eventModel.meta.length > 180 ? eventModel.meta.substring(0, 180) : eventModel.meta,
                      overflow: TextOverflow.fade,
                      softWrap: true,
                      style: const TextStyle(
                          fontSize: 12.0, fontStyle: FontStyle.italic),
                      maxLines: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        eventModel.count == '상시'
                            ? const SizedBox()
                            : Text(
                                '${_dateTimeConverter.convert(eventModel.deadline)}까지'),
                        Text(eventModel.count),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      appBar: DefaultAppBar(),
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
                  CustomCalendar(height: (33 * _eventCalenderController.events.length) + 130,),
                  Divider(),
                  ListTile(
                    title: TitleText('이벤트 바로가기'),
                  ),
                  Obx(buildEventCard),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        tooltip: 'UI 새로고침',
        onPressed: () {
          setState(() {
            _flag = !_flag;
          });
        },
      ),
    );
  }
}
