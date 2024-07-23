import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/common/server_time.dart';
import 'package:karanda/common/time_of_day_extension.dart';
import 'package:karanda/world_boss_timer/models/boss.dart';
import 'package:karanda/world_boss_timer/models/boss_data.dart';
import 'package:karanda/world_boss_timer/models/boss_queue.dart';
import 'package:karanda/world_boss_timer/models/event_boss_data.dart';
import 'package:karanda/world_boss_timer/models/spawn_time.dart';

class BossTimerController {
  final BossQueue _bossQueue = BossQueue();
  final StreamController<BossQueue> _queueStreamController = StreamController<BossQueue>();
  late Map<String, BossData> fixedBosses;
  late Map<String, EventBossData> eventBosses;
  Map<TimeOfDay, Set<String>> timeTable = {};
  final List<TimeOfDay> _spawnTimes = [];
  final ServerTime _serverTime = ServerTime();
  late StreamSubscription _subscription;

  Stream<BossQueue> get stream => _queueStreamController.stream;

  BossTimerController() {
    init();
  }

  Future<void> init() async {
    await getBaseData();
    initializeBossQueue();
    _subscription = _serverTime.stream.listen(check);
  }

  Future<void> getBaseData() async {
    Map data =
        jsonDecode(await rootBundle.loadString('assets/data/world_boss.json'));

    fixedBosses = {};
    for (String key in data["fixed"].keys) {
      BossData bossData = BossData.fromData(data["fixed"][key]);
      fixedBosses[bossData.name] = bossData;
      for (SpawnTime spawnTime in bossData.spawnTimesKR) {
        if (timeTable.containsKey(spawnTime.timeOfDay)) {
          timeTable[spawnTime.timeOfDay]?.add(bossData.name);
        } else {
          timeTable[spawnTime.timeOfDay] = {bossData.name};
          _spawnTimes.add(spawnTime.timeOfDay);
        }
      }
    }

    eventBosses = {};
    for (String key in data["event"].keys) {
      EventBossData eventBossData = EventBossData.fromData(data["event"][key]);
      eventBosses[eventBossData.name] = eventBossData;
      for (SpawnTime spawnTime in eventBossData.spawnTimesKR) {
        if (timeTable.containsKey(spawnTime.timeOfDay)) {
          timeTable[spawnTime.timeOfDay]?.add(eventBossData.name);
        } else {
          timeTable[spawnTime.timeOfDay] = {eventBossData.name};
          _spawnTimes.add(spawnTime.timeOfDay);
        }
      }
    }

    _spawnTimes.sort((a, b) => a.compareTo(b));
    print(timeTable);
  }

  /* 시간이 업데이트 될 때 마다 보스 확인 */
  void check(snapshot){
    DateTime now = snapshot;
    //print(_bossQueue.next.spawnTime.difference(now));
    if(_bossQueue.next.spawnTime.difference(now).inSeconds < 0){
      updateBossQueue();
    }
  }

  void updateBossQueue(){
    TimeOfDay time = TimeOfDay.fromDateTime(_bossQueue.next.spawnTime);
    DateTime serverDate = _serverTime.now.toDate();
    int index = _spawnTimes.indexOf(time);
    _bossQueue.previous = _bossQueue.next;
    _bossQueue.next = _bossQueue.followed;
    if(time == _spawnTimes.last){
      serverDate = serverDate.add(const Duration(days: 1));
      index = 0;
    } else {
      index += 1;
    }
    while(true){
      DateTime spawnTime = serverDate.copyWith(hour: _spawnTimes[index].hour, minute: _spawnTimes[index].minute);
      List<BossData> fixed = getFixedBosses(spawnTime);
      List<EventBossData> event = getEventBosses(spawnTime);
      if(fixed.isNotEmpty || event.isNotEmpty){
        _bossQueue.followed = Boss(spawnTime);
        _bossQueue.followed.fixed = fixed;
        _bossQueue.followed.event = event;
        break;
      }

      if(index == _spawnTimes.length - 1){
        serverDate = serverDate.add(const Duration(days: 1));
        index = 0;
      } else {
        index++;
      }
    }

    _queueStreamController.sink.add(_bossQueue);
  }

  void initializeBossQueue() {
    DateTime time = _serverTime.now.toDate();
    int index = _spawnTimes.length - 1;

    /* get previous boss */
    while(true){
      time = time.copyWith(hour: _spawnTimes[index].hour, minute: _spawnTimes[index].minute);
      if(time.isBefore(_serverTime.now)){
        List<BossData> fixed = getFixedBosses(time);
        List<EventBossData> event = getEventBosses(time);
        if(fixed.isNotEmpty || event.isNotEmpty){
          _bossQueue.previous = Boss(time);
          _bossQueue.previous.fixed = fixed;
          _bossQueue.previous.event = event;
          break;
        }
      }

      if(index == 0){
        time = time.subtract(const Duration(days: 1));
        index = _spawnTimes.length - 1;
      } else {
        index--;
      }
    }

    /* get next boss */
    while(true){
      time = time.copyWith(hour: _spawnTimes[index].hour, minute: _spawnTimes[index].minute);
      if(time.isAfter(_serverTime.now)){
        List<BossData> fixed = getFixedBosses(time);
        List<EventBossData> event = getEventBosses(time);
        if(fixed.isNotEmpty || event.isNotEmpty){
          _bossQueue.next = Boss(time);
          _bossQueue.next.fixed = fixed;
          _bossQueue.next.event = event;
          index++;
          break;
        }
      }

      if(index == _spawnTimes.length - 1){
        time = time.add(const Duration(days: 1));
        index = 0;
      } else {
        index++;
      }
    }

    /* get followed boss */
    if(index == _spawnTimes.length){
      time = time.add(const Duration(days: 1));
      index = 0;
    }
    while(true){
      time = time.copyWith(hour: _spawnTimes[index].hour, minute: _spawnTimes[index].minute);
      List<BossData> fixed = getFixedBosses(time);
      List<EventBossData> event = getEventBosses(time);
      if(fixed.isNotEmpty || event.isNotEmpty){
        _bossQueue.followed = Boss(time);
        _bossQueue.followed.fixed = fixed;
        _bossQueue.followed.event = event;
        break;
      }

      if(index == _spawnTimes.length - 1){
        time = time.add(const Duration(days: 1));
        index = 0;
      } else {
        index++;
      }
    }
    _queueStreamController.sink.add(_bossQueue);
  }

  List<BossData> getFixedBosses(DateTime time) {
    TimeOfDay timeOfDay = TimeOfDay.fromDateTime(time);
    List<BossData> result = [];
    for (String name in timeTable[timeOfDay]!) {
      if (fixedBosses.containsKey(name) && fixedBosses[name]!.check(time)) {
        result.add(fixedBosses[name]!);
      }
    }
    return result;
  }

  List<EventBossData> getEventBosses(DateTime time) {
    TimeOfDay timeOfDay = TimeOfDay.fromDateTime(time);
    List<EventBossData> result = [];
    for (String name in timeTable[timeOfDay]!) {
      if (eventBosses.containsKey(name) && eventBosses[name]!.check(time)) {
        EventBossData target = eventBosses[name]!;
        if (target.start.isBefore(_serverTime.now) &&
            target.end.isAfter(_serverTime.now)) {
          result.add(target);
        }
      }
    }
    return result;
  }

  void dispose() {
    _queueStreamController.close();
    _subscription.cancel();
  }
}
