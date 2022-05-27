import 'package:black_tools/event_calender/event_crawler.dart';
import 'package:black_tools/widgets/default_app_bar.dart';
import 'package:flutter/material.dart';

class EventCalenderPage extends StatefulWidget {
  const EventCalenderPage({Key? key}) : super(key: key);

  @override
  State<EventCalenderPage> createState() => _EventCalenderPageState();
}

class _EventCalenderPageState extends State<EventCalenderPage> {
  final EventCrawler _eventCrawler = EventCrawler();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: Center(
        child: Container(
          child: ElevatedButton(
            child: Text('Hello :)'),
            onPressed: (){
              _eventCrawler.getData();
            },
          ),
        ),
      ),
    );
  }
}
