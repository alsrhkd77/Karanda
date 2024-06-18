import 'package:karanda/horse_status/models/horse_spec_model.dart';

class HorseStatusModel {
  int _level = 0;
  HorseSpecModel baseSpec = HorseSpecModel();
  HorseSpecModel finalSpec = HorseSpecModel();
  HorseSpecModel additionalSpec = HorseSpecModel();

  HorseSpecModel totalGrown = HorseSpecModel();
  HorseSpecModel grownAvg = HorseSpecModel();

  int get level => _level;

  set level(int value) {
    if(value < 1){
      _level = 1;
    }
    if(value > 30){
      _level = 30;
    }
  }

  void calculate() {
    totalGrown = finalSpec - baseSpec - additionalSpec;
    if (level == 1) {
      grownAvg = HorseSpecModel();
    } else {
      grownAvg = totalGrown / HorseSpecModel.fromValue(level.toDouble());
    }
  }
}
