import '../horse/horse_info.dart';
import 'package:get/get.dart';

class HorseController extends GetxController {
  final HorseInfo _horseInfo = HorseInfo();

  String _breed = '꿈결 아두아나트';
  int _level = 0; //레벨
  double _speed = 0.0;  //속도
  double _acceleration = 0.0; //가속
  double _brake = 0.0;  //제동
  double _rotForce = 0.0; //회전

  String get breed => _breed;

  set breed(String value) {
    _breed = value;
    update();
  }

  int get level => _level;

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

  double get grownStat => _speed + _acceleration + _brake + _rotForce;

  //등급 계산
  String _evaluate(double value) {
    if (value >= 0.8) {
      return '최상급';
    } else if (value >= 0.75) {
      return '상급';
    } else if (value >= 0.65) {
      return '중급';
    } else if (value >= 0.55) {
      return '하급';
    } else {
      return '최하급';
    }
  }
  
  //평균 성장치
  double get average {
    double defaultStat = _horseInfo.detail[_breed]!.values
        .reduce((value, element) => value + element);
    int maxLevel = _level > 30 ? 30 : _level;
    return ((grownStat - defaultStat) / maxLevel) / 4;
  }

  //등급
  String get grade {
    if(_level <= 0){
      return '??';
    }
    return _evaluate(average);
  }

  double get speedAvg{
    int maxLevel = _level > 30 ? 30 : _level;
    return  (_speed - _horseInfo.detail[_breed]!['속도']!) / maxLevel;
  }

  double get speedPercent => _speed / (_horseInfo.detail[_breed]!['속도']! + (1.3 * 30)) * 100;

  String get speedGrade => _evaluate(speedAvg);

  double get accelerationAvg{
    int maxLevel = _level > 30 ? 30 : _level;
    return  (_acceleration - _horseInfo.detail[_breed]!['가속']!) / maxLevel;
  }

  double get accelerationPercent => _acceleration / (_horseInfo.detail[_breed]!['가속']! + (1.3 * 30)) * 100;
  
  String get accelerationGrade => _evaluate(accelerationAvg);

  double get brakeAvg{
    int maxLevel = _level > 30 ? 30 : _level;
    return  (_brake - _horseInfo.detail[_breed]!['제동']!) / maxLevel;
  }

  double get brakePercent => _brake / (_horseInfo.detail[_breed]!['제동']! + (1.3 * 30)) * 100;

  String get brakeGrade => _evaluate(brakeAvg);

  double get rotForceAvg{
    int maxLevel = _level > 30 ? 30 : _level;
    return  (_rotForce - _horseInfo.detail[_breed]!['회전']!) / maxLevel;
  }

  double get rotForcePercent => _rotForce / (_horseInfo.detail[_breed]!['회전']! + (1.3 * 30)) * 100;

  String get rotForceGrade => _evaluate(rotForceAvg);
}
