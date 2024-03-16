import 'package:karanda/ship_upgrading/ship_upgrading_parts.dart';

class ShipUpgradingShip {
  late String nameKR;
  late String nameEN;
  //late Map<String, ShipUpgradingParts> parts;
  late List<String> parts;

  ShipUpgradingShip.fromData(Map data, Map<String, ShipUpgradingParts> partsData){
    nameKR = data['name']['kr'];
    nameEN = data['name']['en'];
    parts = List<String>.from(data['parts']);

    /*
    Map<String, ShipUpgradingParts> partsData = {};
    for(String key in data['parts']){
      partsData[key] = parts[key]!;
    }
    this.parts = partsData;
     */
  }
}