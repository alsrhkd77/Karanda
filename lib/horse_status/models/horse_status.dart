import 'dart:math';

import 'package:karanda/horse_status/models/horse_spec.dart';

class HorseStatus {
  int level = 1;
  HorseSpec baseSpec = HorseSpec();
  HorseSpec finalSpec = HorseSpec();
  HorseSpec additionalSpec = HorseSpec();

  HorseSpec grownSpec = HorseSpec();
  HorseSpec avgGrownSpec = HorseSpec();

  double _totalGrown = 0.0;
  double _avgTotalGrown = 0.0;

  double get totalGrown => _totalGrown;
  double get avgTotalGrown => _avgTotalGrown;

  void calculate() {
    grownSpec = finalSpec - baseSpec - additionalSpec;
    _totalGrown = grownSpec.speed + grownSpec.accel + grownSpec.turn + grownSpec.brake;
    _totalGrown = max(0, _totalGrown);
    if (level <= 1) {
      avgGrownSpec = HorseSpec();
      _avgTotalGrown = 0.0;
    } else if (level > 30) {
      avgGrownSpec = grownSpec / HorseSpec.fromValue(29.0);
      _avgTotalGrown = _totalGrown / 30.0 / 4.0;
    } else {
      avgGrownSpec = grownSpec / HorseSpec.fromValue((level-1).toDouble());
      _avgTotalGrown = _totalGrown / level.toDouble() / 4.0;
    }
  }
}
