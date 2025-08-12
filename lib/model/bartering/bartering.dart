import 'package:flutter/widgets.dart';
import 'package:karanda/model/bartering/bartering_mastery.dart';

class Bartering {
  String exchangePoint; //교환처
  int requiredParley;
  double inputWeight;
  double outputWeight;
  final TextEditingController countTextController = TextEditingController();
  int reducedParley;
  int count;

  Bartering({
    required this.exchangePoint,
    this.requiredParley = 0,
    this.inputWeight = 0,
    this.outputWeight = 0,
    this.count = 0,
  }) : reducedParley = requiredParley;

  int get totalParley => reducedParley * count;

  void decreasesParley({
    required BarteringMastery mastery,
    required bool useValuePack,
    required bool useCleia,
  }) {
    double reductionRate = mastery.reductionRate;
    if (useValuePack) {
      reductionRate += 0.1;
    }
    if (useCleia) {
      reductionRate += 0.1;
    }
    reducedParley = (requiredParley * (1.0 - reductionRate)).floor();
  }
}
