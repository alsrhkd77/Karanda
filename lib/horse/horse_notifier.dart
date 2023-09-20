import 'package:flutter/foundation.dart';

import 'horse_info.dart';

class HorseNotifier with ChangeNotifier {
  String _breed = '꿈결 아두아나트';
  int _level = 0; //레벨
  double _speed = 0.0; //속도
  double _acceleration = 0.0; //가속
  double _brake = 0.0; //제동
  double _rotForce = 0.0; //회전

  String get breed => _breed;

  set breed(String value) {
    _breed = value;
    notifyListeners();
  }

  int get level => _level;

  int get maxLevel {
    int max = _level > 30 ? 30 : _level;
    return max - 1;
  }

  set level(int value) {
    _level = value;
    notifyListeners();
  }

  double get speed => _speed;

  set speed(double value) {
    _speed = value;
    notifyListeners();
  }

  double get acceleration => _acceleration;

  set acceleration(double value) {
    _acceleration = value;
    notifyListeners();
  }

  double get brake => _brake;

  set brake(double value) {
    _brake = value;
    notifyListeners();
  }

  double get rotForce => _rotForce;

  set rotForce(double value) {
    _rotForce = value;
    notifyListeners();
  }

  double get grownStat {
    double stat = 0;
    if (_speed > 0) {
      stat += _speed - HorseInfo.detail[_breed]!['속도']!;
    }
    if (_acceleration > 0) {
      stat += _acceleration - HorseInfo.detail[_breed]!['가속']!;
    }
    if (_brake > 0) {
      stat += _brake - HorseInfo.detail[_breed]!['제동']!;
    }
    if (_rotForce > 0) {
      stat += _rotForce - HorseInfo.detail[_breed]!['회전']!;
    }
    return stat;
  }

  //등급 계산
  String _evaluate(double value) {
    if (value >= 0.85) {
      return '최상급';
    } else if (value >= 0.80) {
      return '상급';
    } else if (value >= 0.75) {
      return '중급';
    } else if (value >= 0.70) {
      return '하급';
    } else {
      return '최하급';
    }
  }

  //평균 성장치
  double get average {
    if(maxLevel <= 0){
      return 0.0;
    }
    return doubleFloor((grownStat / maxLevel) / 4);
  }

  double doubleFloor(double value){
    double result = value * 100;
    result = result.floor() / 100;
    return result;
  }

  //등급
  String get grade {
    if (_level <= 0) {
      return '??';
    }
    return _evaluate(average);
  }

  double percent(double value){
    if(maxLevel <= 0){
      return 0.1;
    }
    double result = (value / 1.3) * 100;
    return result;
  }

  double get speedAvg {
    if(_speed <= HorseInfo.detail[_breed]!['속도']! || maxLevel <= 0){
      return 0.0;
    }
    return doubleFloor((_speed - HorseInfo.detail[_breed]!['속도']!) / maxLevel);
  }

  String get speedGrade => _evaluate(speedAvg);

  double get speedPercent => percent(speedAvg);

  double get accelerationAvg {
    if(_acceleration <= HorseInfo.detail[_breed]!['가속']! || maxLevel <= 0){
      return 0.0;
    }
    return doubleFloor((_acceleration - HorseInfo.detail[_breed]!['가속']!) / maxLevel);
  }

  String get accelerationGrade => _evaluate(accelerationAvg);

  double get accelerationPercent => percent(accelerationAvg);

  double get brakeAvg {
    if(_brake <= HorseInfo.detail[_breed]!['제동']! || maxLevel <= 0){
      return 0.0;
    }
    return doubleFloor((_brake - HorseInfo.detail[_breed]!['제동']!) / maxLevel);
  }

  String get brakeGrade => _evaluate(brakeAvg);

  double get brakePercent => percent(brakeAvg);

  double get rotForceAvg {
    if(_rotForce <= HorseInfo.detail[_breed]!['회전']! || maxLevel <= 0){
      return 0.0;
    }
    return doubleFloor((_rotForce - HorseInfo.detail[_breed]!['회전']!) / maxLevel);
  }

  String get rotForceGrade => _evaluate(rotForceAvg);

  double get rotForcePercent => percent(rotForceAvg);
}