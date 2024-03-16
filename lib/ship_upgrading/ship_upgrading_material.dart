import 'package:flutter/widgets.dart';

class ShipUpgradingMaterial {
  late int code;
  late String nameKR;
  late int price;
  late int grade;
  late ObtainDetail obtain;
  final controller = TextEditingController();
  int userStock = 0;
  int totalNeeded = 0;
  int finished = 0;

  double get _stockPoint => obtain.reward > 0
      ? (userStock + finished) / obtain.reward
      : (userStock + finished) / obtain.trade;

  double get neededPoint => obtain.reward > 0
      ? totalNeeded / obtain.reward
      : totalNeeded / obtain.trade;

  double get stockPoint =>
      _stockPoint > neededPoint ? neededPoint : _stockPoint;

  ShipUpgradingMaterial.fromData(Map data) {
    code = data['code'];
    nameKR = data['name']['kr'];
    price = data['price'];
    grade = 0;
    obtain = ObtainDetail.fromData(data['obtain']);
  }
}

class ObtainDetail {
  late String name;
  late String detail;
  late String npc;
  late int reward;
  late int trade;

  String get nameWithNpc => reward > 0 ? '$name - $npc' : name;

  String get detailWithReward => reward > 0 ? '$detail, 보상 $reward개' : detail;

  ObtainDetail.fromData(Map data) {
    name = data['name'];
    detail = data['detail'];
    npc = data['npc'];
    reward = data['reward'];
    trade = 1;
  }
}
