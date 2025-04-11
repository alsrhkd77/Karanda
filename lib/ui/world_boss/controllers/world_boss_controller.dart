import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/model/world_boss_schedule_set.dart';
import 'package:karanda/service/world_boss_service.dart';

class WorldBossController extends ChangeNotifier {
  final WorldBossService _worldBossService;
  late final StreamSubscription _schedule;

  WorldBossScheduleSet? schedule;

  WorldBossController({required WorldBossService worldBossService})
      : _worldBossService = worldBossService {
    _schedule = _worldBossService.currentSchedule.listen(_updateSchedule);
  }

  void _updateSchedule(WorldBossScheduleSet value){
    schedule = value;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _schedule.cancel();
    super.dispose();
  }
}
