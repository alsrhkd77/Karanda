import 'package:karanda/horse_status/models/horse_spec.dart';

class Horse {
  late String type;
  late String nameKR;
  late String nameEN;
  late HorseSpec spec;

  Horse.fromData(Map data) {
    type = data['type'];
    nameKR = data['name']['kr'];
    nameEN = data['name']['en'];
    spec = HorseSpec(
      speed: data['spec']['speed'],
      accel: data['spec']['accel'],
      turn: data['spec']['turn'],
      brake: data['spec']['brake'],
    );
  }

  static String getGrade(double value) {
    if (value > 0.85) {
      return '최상급';
    } else if (value > 0.81) {
      return '상급';
    } else if (value > 0.78) {
      return '중급';
    } else if (value > 0.75) {
      return '하급';
    } else {
      return '최하급';
    }
  }
}
