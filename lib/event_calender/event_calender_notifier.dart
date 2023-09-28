import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:karanda/common/date_time_extension.dart';

import 'event_model.dart';
import 'package:http/http.dart' as http;

class EventCalenderNotifier with ChangeNotifier {
  List<EventModel> _events = [];
  String _lastUpdate = ' - ';
  int _limit = 30;
  String _filter = 'ascending';

  String get lastUpdate => _lastUpdate;

  List<EventModel> get events => _filtering(_events)
      .where((p0) => !p0.deadline.isAtSameMomentAs(DateTime(2996, 11, 12)))
      .toList();

  List<EventModel> get allEvents => _filtering(_events);

  Future<List<EventModel>> getData() async {
    List<EventModel> result = [];
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/HwanSangYeonHwa/black_event/main/events.json'));

    Map body = jsonDecode(response.body);
    List data = body['events'];
    DateTime lastUpdate = DateTime.parse(body['last_update']);
    _lastUpdate = lastUpdate.format('yy.MM.dd HH:mm:ss');

    for (Map e in data) {
      String title = e['title'];
      String count = e['count'];
      String url = e['url'];
      String thumbnail = e['thumbnail'];
      String meta = e['meta'];
      DateTime deadline = DateTime(2996, 11, 12);
      if (!count.contains('상시')) {
        deadline = DateTime.parse(e['deadline']);
        DateTime utcTime = DateTime.now().toUtc().add(const Duration(hours: 9));
        Duration deadlineCount = deadline.difference(deadline.copyWith(
            year: utcTime.year, month: utcTime.month, day: utcTime.day));
        count = '${deadlineCount.inDays + 1} 일 남음';
      }
      result.add(
        EventModel(
            title.replaceAll('[이벤트]', '').trim(),
            count,
            deadline,
            url,
            thumbnail,
            meta,
            Colors
                .primaries[Random().nextInt(Colors.primaries.length)].shade100),
      );
    }
    _events = result;

    notifyListeners();
    return result;
  }

  void setFilter(var value) {
    if (value == null) {
      return;
    } else if (value == '오름차순') {
      _filter = 'ascending';
    } else if (value == '내림차순') {
      _filter = 'descending';
    } else if (value == '무작위') {
      _filter = 'random';
    } else if (value == '7일 이내') {
      _limit = 7;
    } else if (value == '30일 이내') {
      _limit = 30;
    } else if (value == '전체') {
      _limit = 999;
    }
    notifyListeners();
  }

  List<EventModel> _filtering(List<EventModel> e) {
    List<EventModel> list = e;
    if (_filter == 'random') {
      list.shuffle();
    }
    list.sort((a, b) => a.deadline.difference(b.deadline).inDays);
    if (_filter == 'descending') {
      list = e.reversed.toList();
    }
    return list
        .where((element) => element.deadline
            .isBefore(DateTime.now().add(Duration(days: _limit))))
        .toList();
  }
}
