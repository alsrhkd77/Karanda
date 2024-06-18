import 'package:karanda/horse_status/models/horse_spec_model.dart';

class HorsePearlEquipmentModel{
  late int code;
  late String type;
  late String nameKR;
  late String nameEN;
  late HorseSpecModel spec;

  HorsePearlEquipmentModel.fromData(Map data){
    code = data['code'];
    type = data['type'];
    nameKR = data['name']['kr'];
    nameEN = data['name']['en'];
    spec = HorseSpecModel.fromData(data['spec']);
  }
}