import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:karanda/world_boss_timer/models/boss_queue.dart';

class BossTimerController {
  late BossQueue _bossQueue;
  StreamController queueStreamController = StreamController<BossQueue>();

  Stream get stream => queueStreamController.stream;

  BossTimerController(){
    getBaseData();
  }

  Future<void> getBaseData() async {
    Map data = jsonDecode(await rootBundle.loadString('assets/data/world_boss.json'));
  }

  void dispose(){

  }
}