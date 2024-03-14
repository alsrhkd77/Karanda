import 'package:flutter/widgets.dart';

class ShipUpgradingMaterial {
  late int code;
  late String nameKR;
  late int price;
  late ObtainDetail obtain;
  final controller = TextEditingController();
  int userStock = 0;

  ShipUpgradingMaterial.fromData(Map data){
    code = data['code'];
    nameKR = data['name']['kr'];
    price = data['price'];
    obtain = ObtainDetail.fromData(data['obtain']);
  }
}

class ObtainDetail {
  late String name;
  late String detail;
  late String npc;
  late int reward;

  ObtainDetail.fromData(Map data){
    name = data['name'];
    detail = data['detail'];
    npc = data['npc'];
    reward = data['reward'];
  }
}
