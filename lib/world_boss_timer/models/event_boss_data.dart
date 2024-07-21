import 'package:karanda/world_boss_timer/models/boss_data.dart';

class EventBossData extends BossData {
  late DateTime start;
  late DateTime end;

  EventBossData.fromData(Map data) : super.fromData(data){
    start = DateTime.parse(data["start"]);
    end = DateTime.parse(data["end"]);
  }

}