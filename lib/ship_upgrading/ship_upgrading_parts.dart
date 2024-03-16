enum ShipParts { figurehead, plating, cannon, windSail, license }

class ShipUpgradingParts {
  late int code;
  late String nameKR;
  late ShipParts type;
  late int grade;
  late Map<String, MaterialsNeeded> materials;

  late bool finished;

  ShipUpgradingParts.fromData(Map data){
    code = data['code'];
    nameKR = data['name']['kr'];
    type = ShipParts.values.byName(data['type']);
    grade = data['grade'];

    Map<String, MaterialsNeeded> materialData = {};
    for(String key in (data['materials'] as Map).keys){
      materialData[key] = MaterialsNeeded.fromData(data['materials'][key]);
    }
    materials = materialData;
  }
}

class MaterialsNeeded {
  late int code;
  late int need;
  late int days;

  MaterialsNeeded.fromData(Map data) {
    code = data['code'];
    need = data['need'];
  }
}
