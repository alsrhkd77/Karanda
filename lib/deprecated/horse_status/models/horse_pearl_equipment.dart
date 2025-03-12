
import 'horse_spec.dart';

class HorsePearlEquipment{
  late int code;
  late String type;
  late String nameKR;
  late String nameEN;
  late HorseSpec spec;

  HorsePearlEquipment.fromData(Map data){
    code = data['code'];
    type = data['type'];
    nameKR = data['name']['kr'];
    nameEN = data['name']['en'];
    spec = HorseSpec.fromData(data['spec']);
  }
}