import 'dart:convert';

import 'package:karanda/common/date_time_extension.dart';

import 'checklist_finished_item.dart';

enum Cycle { once, daily, weeklyMon, weeklyThu }

class ChecklistItem {
  int? id;
  late String title;
  bool enabled = true;
  Cycle cycle = Cycle.daily;
  List<ChecklistFinishedItem> finishedItem = [];

  ChecklistItem({required this.title, required this.cycle});

  ChecklistItem.fromJson(String json) {
    Map<String, Cycle> match = {
      'once': Cycle.once,
      'daily': Cycle.daily,
      'weekly_mon': Cycle.weeklyMon,
      'weekly_thu': Cycle.weeklyThu,
    };
    Map data = jsonDecode(json);
    id = data['id'];
    title = data['title'];
    enabled = data['enabled'];
    cycle = match[data['cycle']]!;
  }

  ChecklistItem.fromData(Map data) {
    Map<String, Cycle> match = {
      'once': Cycle.once,
      'daily': Cycle.daily,
      'weekly_mon': Cycle.weeklyMon,
      'weekly_thu': Cycle.weeklyThu,
    };
    id = data['id'];
    title = data['title'];
    enabled = data['enabled'];
    cycle = match[data['cycle']]!;
    for (Map m in data['finished_items']) {
      ChecklistFinishedItem item = ChecklistFinishedItem.fromData(m);
      finishedItem.add(item);
    }
  }

  String toJson({bool withFinishedItem = false}) {
    Map<Cycle, String> match = {
      Cycle.once: 'once',
      Cycle.daily: 'daily',
      Cycle.weeklyMon: 'weekly_mon',
      Cycle.weeklyThu: 'weekly_thu',
    };
    Map data = {
      'title': title,
      'enabled': enabled,
      'cycle': match[cycle],
    };
    if (id != null){
      data['id'] = id;
    }
    if (withFinishedItem) {
      data['finished_items'] = finishedItem.map((e) => e.toJson());
    }
    return jsonEncode(data);
  }

  int? isFinished(DateTime selected) {
    int? result;
    switch (cycle) {
      case Cycle.once:
        if (finishedItem.isNotEmpty) {
          result = 0;
        }
        break;
      case Cycle.daily:
        for (int i = 0; i < finishedItem.length; i++) {
          if (finishedItem[i].finishAt.toDate() == selected.toDate()) {
            result = i;
          }
        }
        break;
      case Cycle.weeklyMon:
        late DateTime monday;
        for (int i = 0; i < 7; i++) {
          DateTime day = selected.subtract(Duration(days: i));
          if (day.weekday == DateTime.monday) {
            monday = day.toDate().subtract(const Duration(microseconds: 1));
            break;
          }
        }
        for (int i = 0; i < finishedItem.length; i++) {
          if (monday.isBefore(finishedItem[i].finishAt) &&
              monday
                  .add(const Duration(days: 7))
                  .isAfter(finishedItem[i].finishAt)) {
            result = i;
          }
        }
        break;
      case Cycle.weeklyThu:
        late DateTime thursday;
        for (int i = 0; i < 7; i++) {
          DateTime day = selected.subtract(Duration(days: i));
          if (day.weekday == DateTime.thursday) {
            thursday = day.toDate().subtract(const Duration(microseconds: 1));
            break;
          }
        }
        for (int i = 0; i < finishedItem.length; i++) {
          if (thursday.isBefore(finishedItem[i].finishAt) &&
              thursday
                  .add(const Duration(days: 7))
                  .isAfter(finishedItem[i].finishAt)) {
            result = i;
          }
        }
        break;
      default:
        break;
    }
    return result;
  }
}
