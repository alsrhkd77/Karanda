import 'dart:async';

import 'package:media_kit/media_kit.dart';

class AudioController {
  final Player _bossAlarm = Player();
  final Player _notification = Player();

  double _volume = 50.0;
  final StreamController<double> _volumeController = StreamController<double>.broadcast();
  Stream<double> get volume => _volumeController.stream;

  static final AudioController _instance = AudioController._internal();

  factory AudioController() => _instance;

  AudioController._internal(){
    _init();
  }

  Future<void> _init() async {
    await _bossAlarm.open(Media("asset:///assets/sounds/boss_alarm.mp3"), play: false);
    await _bossAlarm.setVolume(_volume);
    await _notification.open(Media("asset:///assets/sounds/notification.mp3"), play: false);
    await _notification.setVolume(_volume);
  }

  Future<void> bossAlarm() async {
    await _bossAlarm.setVolume(_volume);
    await _bossAlarm.play();
  }

  Future<void> notification() async {
    await _notification.setVolume(_volume);
    await _notification.play();
  }

  void subscribe(){
    _volumeController.sink.add(_volume);
  }

  void setVolume(double value){
    if(value < 0.0) value = 0.0;
    if(value > 100.0) value = 100.0;
    _volume = value;
    _volumeController.sink.add(_volume);
  }
}