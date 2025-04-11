import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';

import 'boss_data.dart';
import 'event_boss_data.dart';

class Boss {
  late DateTime spawnTime;
  List<BossData> fixed = [];
  List<EventBossData> event = [];

  Boss(this.spawnTime);

  String get names => _getNamesOfBosses();

  List<String> get nameList => _getNameListOfBosses();

  String _getNamesOfBosses() {
    String result = '';
    for (int index = 0; index < nameList.length; index++) {
      if (index == 2) {
        result = '$result,\n${nameList[index].tr()}';
      } else {
        result = '$result, ${nameList[index].tr()}';
      }
    }
    result = result.replaceFirst(', ', '');
    return result;
  }

  List<String> _getNameListOfBosses() {
    List<String> result = [];
    for (BossData data in fixed) {
      result.add(data.name);
    }
    for (EventBossData data in event) {
      result.add(data.name);
    }
    return result;
  }

  String toMessage() {
    Map data = {
      "spawnTime": spawnTime.toString(),
      "names": _getNamesOfBosses()
    };
    return jsonEncode(data);
  }
}
