import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:karanda/world_boss/models/boss_data.dart';
import 'package:karanda/world_boss/models/event_boss_data.dart';

class Boss {
  late DateTime spawnTime;
  List<BossData> fixed = [];
  List<EventBossData> event = [];

  Boss(this.spawnTime);

  String get names => _getNamesOfBosses();

  List<String> get nameList => _getNameListOfBosses();

  String _getNamesOfBosses(){
    String result = '';
    for(String name in nameList){
      result = '$result, ${name.tr()}';
    }
    result = result.replaceFirst(', ', '');
    return result;
  }

  List<String> _getNameListOfBosses(){
    List<String> result = [];
    for(BossData data in fixed){
      result.add(data.name);
    }
    for(EventBossData data in event){
      result.add(data.name);
    }
    return result;
  }

  String toMessage(){
    Map data = {
      "spawnTime": spawnTime.toString(),
      "names": _getNamesOfBosses()
    };
    return jsonEncode(data);
  }
}