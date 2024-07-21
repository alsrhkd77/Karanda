import 'package:karanda/world_boss_timer/models/boss_data.dart';
import 'package:karanda/world_boss_timer/models/event_boss_data.dart';

class Boss {
  late DateTime spawnTime;
  List<BossData> fixed = [];
  List<EventBossData> event = [];

  Boss(this.spawnTime);
}