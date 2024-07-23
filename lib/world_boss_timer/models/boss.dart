import 'package:easy_localization/easy_localization.dart';
import 'package:karanda/world_boss_timer/models/boss_data.dart';
import 'package:karanda/world_boss_timer/models/event_boss_data.dart';

class Boss {
  late DateTime spawnTime;
  List<BossData> fixed = [];
  List<EventBossData> event = [];

  Boss(this.spawnTime);

  String get names => _getNamesOfBosses();

  String _getNamesOfBosses(){
    String result = '';
    for(BossData data in fixed){
      result = '$result, ${data.name.tr()}';
    }
    for(EventBossData data in event){
      result = '$result, ${data.name.tr()}';
    }
    result = result.replaceFirst(', ', '');
    return result;
  }
}