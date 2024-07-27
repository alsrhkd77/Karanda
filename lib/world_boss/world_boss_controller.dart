import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karanda/common/audio_controller.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/common/server_time.dart';
import 'package:karanda/common/time_of_day_extension.dart';
import 'package:karanda/overlay/overlay_window.dart';
import 'package:karanda/world_boss/models/boss.dart';
import 'package:karanda/world_boss/models/boss_data.dart';
import 'package:karanda/world_boss/models/boss_queue.dart';
import 'package:karanda/world_boss/models/event_boss_data.dart';
import 'package:karanda/world_boss/models/spawn_time.dart';
import 'package:karanda/world_boss/models/world_boss_setting.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorldBossController {
  final BossQueue _bossQueue = BossQueue();
  late WorldBossSetting _settings;
  late List<bool> _alarm;
  final StreamController<BossQueue> _queueStreamController =
      StreamController<BossQueue>.broadcast();
  final StreamController<WorldBossSetting> _settingsStreamController = StreamController<WorldBossSetting>.broadcast();
  late Map<String, BossData> fixedBosses;
  late Map<String, EventBossData> eventBosses;
  Map<TimeOfDay, Set<String>> timeTable = {};
  final List<TimeOfDay> _spawnTimes = [];
  final ServerTime _serverTime = ServerTime();
  late StreamSubscription _subscription;
  late OverlayWindow overlay;
  final AudioController _audioController = AudioController();
  bool _regeneration = false; // 보스 출현

  static final WorldBossController _instance = WorldBossController._internal();

  Stream<BossQueue> get stream => _queueStreamController.stream;
  Stream<WorldBossSetting> get settings => _settingsStreamController.stream;

  factory WorldBossController() => _instance;

  WorldBossController._internal(){
    _init();
  }

  Future<void> _init() async {
    await _getBaseData();
    _initializeBossQueue();
    await _getSettings();
    if(!kIsWeb){
      await overlay.create();
      await Future.delayed(const Duration(milliseconds: 500));
      overlay.invokeMethod(method: "next boss", arguments: _bossQueue.next.toMessage());
    }
    _subscription = _serverTime.stream.listen(_check);
  }

  /* 시간이 업데이트 될 때 마다 보스 확인 */
  Future<void> _check(snapshot) async {
    DateTime now = snapshot;
    Duration diff = _bossQueue.next.spawnTime.difference(now);
    if (diff.inSeconds <= -60) {
      _updateBossQueue();
    } else if(diff.inSeconds < 0 && !_regeneration){
      _alert();
      _regeneration = true;
    } else {
      List<int> list = _settings.alarm;
      list.sort();
      for(int i =0; i<list.length;i++){
        if(diff.inMinutes == list[i] - 1 && !_alarm[i]){
          _alert();
          _alarm[i] = true;
          break;
        }
      }
    }
  }

  /* 오버레이에 전송, 알림을 재생 */
  void _alert(){
    if(_settings.useOverlay){
      overlay.invokeMethod(method: "alert", arguments: _bossQueue.next.toMessage());
    }
    if(_settings.useAlarm){
      _audioController.bossAlarm();
    }
  }

  Future<void> _getSettings() async {
    String key = "world_boss";
    final sharedPreferences = await SharedPreferences.getInstance();
    String? settingsData = sharedPreferences.getString('${key}_settings');
    if(settingsData == null){
      _settings = WorldBossSetting.fromJson({});
    } else{
      _settings = WorldBossSetting.fromJson(jsonDecode(settingsData));
    }
    _settingsStreamController.sink.add(_settings);

    Duration diff = _bossQueue.next.spawnTime.difference(_serverTime.now);
    _alarm = [];
    for(int minutes in _settings.alarm){
      if(diff.inMinutes - minutes <= 1){  // 2분 이하로 남은 알림 안띄우게
        _alarm.add(true);
      } else {
        _alarm.add(false);
      }
    }
    if(!kIsWeb){
      String overlayData = sharedPreferences.getString('${key}_overlay') ?? "";
      if(overlayData.isEmpty){
        Display primary = await screenRetriever.getPrimaryDisplay();
        overlay = OverlayWindow.fromJson({
          "title": "Karanda - World Boss",
          "x": primary.size.width - 420.0,
          "y": primary.size.height - 220.0,
          "width": 380.0,
          "height": 180.0,
          "show": true
        });
      } else {
        overlay = OverlayWindow.fromJson(jsonDecode(overlayData));
      }
    }
  }

  Future<void> _getBaseData() async {
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
  }

  void _updateBossQueue() {
    TimeOfDay time = TimeOfDay.fromDateTime(_bossQueue.followed.spawnTime);
    DateTime serverDate = _serverTime.now.toDate();
    int index = _spawnTimes.indexOf(time);
    _bossQueue.previous = _bossQueue.next;
    _bossQueue.next = _bossQueue.followed;
    if (time == _spawnTimes.last) {
      serverDate = serverDate.add(const Duration(days: 1));
      index = 0;
    } else {
      index += 1;
    }
    while (true) {
      DateTime spawnTime = serverDate.copyWith(
          hour: _spawnTimes[index].hour, minute: _spawnTimes[index].minute);
      if(spawnTime.isAfter(_bossQueue.next.spawnTime)){
        List<BossData> fixed = _getFixedBosses(spawnTime);
        List<EventBossData> event = _getEventBosses(spawnTime);
        if (fixed.isNotEmpty || event.isNotEmpty) {
          _bossQueue.followed = Boss(spawnTime);
          _bossQueue.followed.fixed = fixed;
          _bossQueue.followed.event = event;
          break;
        }
      }

      if (index == _spawnTimes.length - 1) {
        serverDate = serverDate.add(const Duration(days: 1));
        index = 0;
      } else {
        index++;
      }
    }

    _queueStreamController.sink.add(_bossQueue);

    if(!kIsWeb){
      overlay.invokeMethod(method: "next boss", arguments: _bossQueue.next.toMessage());
    }

    for(int i = 0; i < _alarm.length; i++){
      _alarm[i] = false;
    }
    _regeneration = false;
  }

  void _initializeBossQueue() {
    DateTime time = _serverTime.now.toDate();
    int index = _spawnTimes.length - 1;

    /* get previous boss */
    while (true) {
      time = time.copyWith(
          hour: _spawnTimes[index].hour, minute: _spawnTimes[index].minute);
      if (time.isBefore(_serverTime.now)) {
        List<BossData> fixed = _getFixedBosses(time);
        List<EventBossData> event = _getEventBosses(time);
        if (fixed.isNotEmpty || event.isNotEmpty) {
          _bossQueue.previous = Boss(time);
          _bossQueue.previous.fixed = fixed;
          _bossQueue.previous.event = event;
          break;
        }
      }

      if (index == 0) {
        time = time.subtract(const Duration(days: 1));
        index = _spawnTimes.length - 1;
      } else {
        index--;
      }
    }

    /* get next boss */
    while (true) {
      time = time.copyWith(
          hour: _spawnTimes[index].hour, minute: _spawnTimes[index].minute);
      if (time.isAfter(_serverTime.now)) {
        List<BossData> fixed = _getFixedBosses(time);
        List<EventBossData> event = _getEventBosses(time);
        if (fixed.isNotEmpty || event.isNotEmpty) {
          _bossQueue.next = Boss(time);
          _bossQueue.next.fixed = fixed;
          _bossQueue.next.event = event;
          index++;
          break;
        }
      }

      if (index == _spawnTimes.length - 1) {
        time = time.add(const Duration(days: 1));
        index = 0;
      } else {
        index++;
      }
    }

    /* get followed boss */
    if (index == _spawnTimes.length) {
      time = time.add(const Duration(days: 1));
      index = 0;
    }
    while (true) {
      time = time.copyWith(
          hour: _spawnTimes[index].hour, minute: _spawnTimes[index].minute);
      List<BossData> fixed = _getFixedBosses(time);
      List<EventBossData> event = _getEventBosses(time);
      if (fixed.isNotEmpty || event.isNotEmpty) {
        _bossQueue.followed = Boss(time);
        _bossQueue.followed.fixed = fixed;
        _bossQueue.followed.event = event;
        break;
      }

      if (index == _spawnTimes.length - 1) {
        time = time.add(const Duration(days: 1));
        index = 0;
      } else {
        index++;
      }
    }
    _queueStreamController.sink.add(_bossQueue);
  }

  List<BossData> _getFixedBosses(DateTime time) {
    TimeOfDay timeOfDay = TimeOfDay.fromDateTime(time);
    List<BossData> result = [];
    for (String name in timeTable[timeOfDay]!) {
      if (fixedBosses.containsKey(name) && fixedBosses[name]!.check(time)) {
        result.add(fixedBosses[name]!);
      }
    }
    return result;
  }

  List<EventBossData> _getEventBosses(DateTime time) {
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

  void updateUseAlarm(bool value){
    _settings.useAlarm = value;
    _settingsStreamController.sink.add(_settings);
    _saveWorldBossSettings();
  }

  void updateUseOverlay(bool value){
    _settings.useOverlay = value;
    _settingsStreamController.sink.add(_settings);
    _saveWorldBossSettings();
  }

  void updateAlarm(int index, int minute){
    if(_settings.alarm.contains(minute)){
      return;
    }
    _settings.alarm[index] = minute;
    _settingsStreamController.sink.add(_settings);
    _saveWorldBossSettings();
  }

  Future<void> _saveWorldBossSettings() async {
    String key = "world_boss_settings";
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(key, jsonEncode(_settings.toJson()));
  }

  void subscribe(){
    if(timeTable.isNotEmpty){
      _queueStreamController.sink.add(_bossQueue);
      _settingsStreamController.sink.add(_settings);
    }
  }

  void dispose() {
    _queueStreamController.close();
    _subscription.cancel();
  }
}
