import 'package:black_tools/event_calender/event_data_source.dart';
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
  final PageController _pageController = PageController(initialPage: 0);

  Widget buildPage(){
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: Get.width / 7,
                child: const Text('일요일', textAlign: TextAlign.center),
              ),
              Container(
                width: Get.width / 7,
                child: const Text('월요일', textAlign: TextAlign.center),
              ),
              Container(
                width: Get.width / 7,
                child: const Text('화요일', textAlign: TextAlign.center),
              ),
              Container(
                width: Get.width / 7,
                child: const Text('수요일', textAlign: TextAlign.center),
              ),
              Container(
                width: Get.width / 7,
                child: const Text('목요일', textAlign: TextAlign.center),
              ),
              Container(
                width: Get.width / 7,
                child: const Text('금요일', textAlign: TextAlign.center),
              ),
              Container(
                width: Get.width / 7,
                child: const Text('토요일', textAlign: TextAlign.center),
              ),
            ],
          ),
          Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      child: Column(
        children: [
          ListTile(
            title: Text('month'),
          ),
          SizedBox(
            height: widget.height != null ? widget.height! - 32 : Get.height - 32,
            child: PageView(
              scrollDirection: Axis.horizontal,
              controller: _pageController,
              children: [
                buildPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
