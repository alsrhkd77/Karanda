import 'package:karanda/ship_upgrading/ship_upgrading_parts.dart';

class ShipUpgradingShip {
  late String nameKR;
  late String nameEN;
  late Map<String, ShipUpgradingParts> parts;

  ShipUpgradingShip.fromData(Map data, Map<String, ShipUpgradingParts> parts){
    nameKR = data['name']['kr'];
    nameEN = data['name']['en'];

    Map<String, ShipUpgradingParts> partsData = {};
    for(String key in data['parts']){
      partsData[key] = parts[key]!;
    }
    this.parts = partsData;
  }
}