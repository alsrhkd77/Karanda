import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karanda/common/server_time.dart';
import 'package:karanda/common/time_of_day_extension.dart';

import 'models/world_boss_data.dart';
import 'models/world_boss_schedule.dart';

class WorldBossService {
  List<WorldBossSchedule> _schedules = [];
  Map<String, WorldBossData> _bosses = {};
  final _server = ServerTime();
  int _index = 0; ///next boss schedule index in [_schedules]

  Future<void> _getData() async {
    Map data =
        jsonDecode(await rootBundle.loadString('assets/data/world_boss.json'));
    for (String key in data["fixed"].keys) {
      final jsonData = _JsonData.fromJson(data["fixed"][key]);
      _bosses[key] = jsonData.bossData;
      for (WorldBossSchedule schedule in jsonData.schedules) {
        int index = _schedules.indexOf(schedule);
        if (index == -1) {
          schedule.bosses.add(jsonData.bossData.name);
          _schedules.add(schedule);
        } else {
          _schedules[index].bosses.add(jsonData.bossData.name);
        }
      }
    }

    _schedules.sort(_sortSchedules);
  }

  void setIndex(){
    final now = TimeOfDay.fromDateTime(_server.now);
    int? index;
    for(int i=0;i<_schedules.length;i++){
      final item = _schedules[i];
      if(_server.now.weekday > item.weekday){
        continue;
      } else if(now.compareTo(item.schedule) == -1){
        index = i;
        break;
      } else if(_server.now.weekday < item.weekday){
        index = i;
        break;
      }
    }
    _index = index ?? 0;
  }

  int _sortSchedules(WorldBossSchedule a, WorldBossSchedule b) {
    if (a.weekday == b.weekday) {
      return a.schedule.compareTo(b.schedule);
    } else {
      return a.weekday.compareTo(b.weekday);
    }
  }
}

class _JsonData {
  WorldBossData bossData;
  List<WorldBossSchedule> schedules;

  _JsonData({required this.bossData, required this.schedules});

  factory _JsonData.fromJson(Map data) {
    Set<WorldBossSchedule> temp = {};
    for (Map item in data["kr"]) {
      temp.addAll(WorldBossSchedule.fromJson(item).toList());
    }
    return _JsonData(
      bossData: WorldBossData.fromJson(data),
      schedules: temp.toList(),
    );
  }
}
