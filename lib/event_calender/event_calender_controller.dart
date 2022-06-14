import 'dart:convert';
import 'dart:math';
import '../event_calender/event_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class EventCalenderController extends GetxController {
  RxList<EventModel> _events = <EventModel>[].obs;
  int _limit = 999;

  List<EventModel> get events => _events
      .where((p0) => !p0.deadline.isAtSameMomentAs(DateTime(2996, 11, 12)))
      .where((element) =>
          element.deadline.isBefore(DateTime.now().add(Duration(days: _limit))))
      .toList();

  List<EventModel> get allEvents => _events
      .where((element) =>
          element.deadline.isBefore(DateTime.now().add(Duration(days: _limit))))
      .toList();

  Future<List<EventModel>> getData() async {
    List<EventModel> result = [];
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/HwanSangYeonHwa/black_event/main/events.json'));

    List data = jsonDecode(response.body)['events'];

    for (Map e in data) {
      String title = e['title'];
      String count = e['count'];
      String url = e['url'];
      String thumbnail = e['thumbnail'];
      String meta = e['meta'];
      DateTime deadline = DateTime(2996, 11, 12);
      if (!count.contains('상시')) {
        deadline = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);
        deadline =
            deadline.add(Duration(days: int.parse(count.split(' ')[0]) - 1));
      }
      result.add(
        EventModel(
            title.replaceAll('[이벤트]', '').trim(),
            count,
            deadline,
            url,
            thumbnail,
            meta,
            Colors.primaries[Random().nextInt(Colors.primaries.length)]),
      );
    }
    _events = result.obs;
    _sort();
    _events.refresh();
    return result;
  }

  void setFilter(var value) {
    if (value == null) {
      return;
    } else if (value == '오름차순') {
      _sort();
    } else if (value == '내림차순') {
      _sort();
      _events = _events.reversed.toList().obs;
    } else if (value == '무작위') {
      _events.shuffle();
    } else if (value == '7일 이내') {
      _limit = 7;
    } else if (value == '30일 이내') {
      _limit = 30;
    } else if (value == '전체') {
      _limit = 999;
    }
    _events.refresh();
  }

  void _sort() {
    _events.sort((a, b) => a.deadline.difference(b.deadline).inDays);
  }
}
