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
  StreamController queueStreamController = StreamController<BossQueue>();
  late Map<String, BossData> fixedBosses;
  late Map<String, EventBossData> eventBosses;
  Map<TimeOfDay, Set<String>> timeTable = {};
  final List<TimeOfDay> _spawnTimes = [];
  final ServerTime _serverTime = ServerTime();
  late StreamSubscription _subscription;

  Stream get stream => queueStreamController.stream;

  BossTimerController() {
    init();
  }

  Future<void> init() async {
    await getBaseData();
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
    initializeBossQueue();
  }

  /* 서버 시간이 업데이트 될 때 마다 보스 확인 */
  void check(snapshot){
    DateTime now = snapshot;
    print(_bossQueue.next.spawnTime.difference(now));
    if(_bossQueue.next.spawnTime.difference(now).inSeconds < 0){
      updateBossQueue();
    }
  }

  void updateBossQueue(){

    print("update");
  }

  void initializeBossQueue() {
    DateTime serverDate = _serverTime.now.toDate();
    for (int i = 0; i < _spawnTimes.length; i++) {
      DateTime time = serverDate.copyWith(
          hour: _spawnTimes[i].hour, minute: _spawnTimes[i].minute);
      if (i == _spawnTimes.length - 1 && time.isBefore(_serverTime.now)) {
        time = time.add(const Duration(days: 1));
        setBossQueue(
          previous: time.copyWith(
            hour: _spawnTimes.last.hour,
            minute: _spawnTimes.last.minute,
          ),
          previousTimeOfDay: _spawnTimes.last,
          next: time.copyWith(
            hour: _spawnTimes.first.hour,
            minute: _spawnTimes.first.minute,
          ),
          nextTimeOfDay: _spawnTimes.first,
          followed: time.copyWith(
            hour: _spawnTimes[1].hour,
            minute: _spawnTimes[1].minute,
          ),
          followedTimeOfDay: _spawnTimes[1],
        );
        break;
      } else if (time.isAfter(_serverTime.now)) {
        if (i == _spawnTimes.length - 1) {
          setBossQueue(
            previous: time.copyWith(
              hour: _spawnTimes[i - 1].hour,
              minute: _spawnTimes[i - 1].minute,
            ),
            previousTimeOfDay: _spawnTimes[i - 1],
            next: time,
            nextTimeOfDay: _spawnTimes[i],
            followed: time
                .copyWith(
                  hour: _spawnTimes[0].hour,
                  minute: _spawnTimes[0].minute,
                )
                .add(const Duration(days: 1)),
            followedTimeOfDay: _spawnTimes[0],
          );
        } else if (i == 0) {
          setBossQueue(
            previous: time
                .copyWith(
                  hour: _spawnTimes.last.hour,
                  minute: _spawnTimes.last.minute,
                )
                .subtract(const Duration(days: 1)),
            previousTimeOfDay: _spawnTimes.last,
            next: time,
            nextTimeOfDay: _spawnTimes[i],
            followed: time.copyWith(
              hour: _spawnTimes[i + 1].hour,
              minute: _spawnTimes[i + 1].minute,
            ),
            followedTimeOfDay: _spawnTimes[i + 1],
          );
        } else {
          setBossQueue(
            previous: time.copyWith(
              hour: _spawnTimes[i - 1].hour,
              minute: _spawnTimes[i - 1].minute,
            ),
            previousTimeOfDay: _spawnTimes[i - 1],
            next: time,
            nextTimeOfDay: _spawnTimes[i],
            followed: time.copyWith(
              hour: _spawnTimes[i + 1].hour,
              minute: _spawnTimes[i + 1].minute,
            ),
            followedTimeOfDay: _spawnTimes[i + 1],
          );
        }
        break;
      }
    }
    print(_bossQueue.previous.spawnTime);
    print(_bossQueue.next.spawnTime);
    print(_bossQueue.followed.spawnTime);
  }

  void setBossQueue(
      {required DateTime previous,
      required DateTime next,
      required DateTime followed,
      required TimeOfDay previousTimeOfDay,
      required TimeOfDay nextTimeOfDay,
      required TimeOfDay followedTimeOfDay}) {
    _bossQueue.next = Boss(next);
    _bossQueue.next.fixed = getFixedBosses(nextTimeOfDay);
    _bossQueue.next.event = getEventBosses(nextTimeOfDay);
    _bossQueue.previous = Boss(previous);
    _bossQueue.previous.fixed = getFixedBosses(previousTimeOfDay);
    _bossQueue.previous.event = getEventBosses(previousTimeOfDay);
    _bossQueue.followed = Boss(followed);
    _bossQueue.followed.fixed = getFixedBosses(followedTimeOfDay);
    _bossQueue.followed.event = getEventBosses(followedTimeOfDay);
  }

  List<BossData> getFixedBosses(TimeOfDay timeOfDay) {
    List<BossData> result = [];
    for (String name in timeTable[timeOfDay]!) {
      if (fixedBosses.containsKey(name)) {
        result.add(fixedBosses[name]!);
      }
    }
    return result;
  }

  List<EventBossData> getEventBosses(TimeOfDay timeOfDay) {
    List<EventBossData> result = [];
    for (String name in timeTable[timeOfDay]!) {
      if (eventBosses.containsKey(name)) {
        EventBossData target = eventBosses[name]!;
        if (target.start.isBefore(_serverTime.now) &&
            target.end.isAfter(_serverTime.now)) {
          result.add(target);
        }
      }
    }
    return result;
  }

  //없어도 될듯?
  bool checkEventBoss(String name) {
    if (eventBosses.containsKey(name)) {
      EventBossData target = eventBosses[name]!;
      if (target.start.isBefore(_serverTime.now) &&
          target.end.isAfter(_serverTime.now)) {
        return true;
      }
    }
    return false;
  }

  void dispose() {
    queueStreamController.close();
    _subscription.cancel();
  }
}
