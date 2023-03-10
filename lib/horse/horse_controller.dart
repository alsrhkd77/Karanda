import '../horse/horse_info.dart';
import 'package:get/get.dart';

class HorseController extends GetxController {
  final HorseInfo _horseInfo = HorseInfo();

  String _breed = '꿈결 아두아나트';
  int _level = 0; //레벨
  double _speed = 0.0; //속도
  double _acceleration = 0.0; //가속
  double _brake = 0.0; //제동
  double _rotForce = 0.0; //회전

  String get breed => _breed;

  set breed(String value) {
    _breed = value;
    update();
  }

  int get level => _level;

  int get maxLevel {
    int _maxLevel = _level > 30 ? 30 : _level;
    return _maxLevel - 1;
  }

  set level(int value) {
    _level = value;
    update();
  }

  double get speed => _speed;

  set speed(double value) {
    _speed = value;
    update();
  }

  double get acceleration => _acceleration;

  set acceleration(double value) {
    _acceleration = value;
    update();
  }

  double get brake => _brake;

  set brake(double value) {
    _brake = value;
    update();
  }

  double get rotForce => _rotForce;

  set rotForce(double value) {
    _rotForce = value;
    update();
  }

  double get grownStat {
    double _stat = 0;
    if (_speed > 0) {
      _stat += _speed - _horseInfo.detail[_breed]!['속도']!;
    }
    if (_acceleration > 0) {
      _stat += _acceleration - _horseInfo.detail[_breed]!['가속']!;
    }
    if (_brake > 0) {
      _stat += _brake - _horseInfo.detail[_breed]!['제동']!;
    }
    if (_rotForce > 0) {
      _stat += _rotForce - _horseInfo.detail[_breed]!['회전']!;
    }
    return _stat;
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

  double percent(double _value){
    if(maxLevel <= 0){
      return 0.1;
    }
    double _result = (_value / 1.3) * 100;
    return _result;
  }

  double get speedAvg {
    if(_speed <= _horseInfo.detail[_breed]!['속도']! || maxLevel <= 0){
      return 0.0;
    }
    return doubleFloor((_speed - _horseInfo.detail[_breed]!['속도']!) / maxLevel);
  }

  String get speedGrade => _evaluate(speedAvg);

  double get speedPercent => percent(speedAvg);

  double get accelerationAvg {
    if(_acceleration <= _horseInfo.detail[_breed]!['가속']! || maxLevel <= 0){
      return 0.0;
    }
    return doubleFloor((_acceleration - _horseInfo.detail[_breed]!['가속']!) / maxLevel);
  }

  String get accelerationGrade => _evaluate(accelerationAvg);

  double get accelerationPercent => percent(accelerationAvg);

  double get brakeAvg {
    if(_brake <= _horseInfo.detail[_breed]!['제동']! || maxLevel <= 0){
      return 0.0;
    }
    return doubleFloor((_brake - _horseInfo.detail[_breed]!['제동']!) / maxLevel);
  }

  String get brakeGrade => _evaluate(brakeAvg);

  double get brakePercent => percent(brakeAvg);

  double get rotForceAvg {
    if(_rotForce <= _horseInfo.detail[_breed]!['회전']! || maxLevel <= 0){
      return 0.0;
    }
    return doubleFloor((_rotForce - _horseInfo.detail[_breed]!['회전']!) / maxLevel);
  }

  String get rotForceGrade => _evaluate(rotForceAvg);

  double get rotForcePercent => percent(rotForceAvg);
}
