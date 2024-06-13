import 'package:karanda/horse_status/models/horse_spec_model.dart';

class HorseModel {
  late String type;
  late String nameKR;
  late String nameEN;
  late HorseSpecModel spec;

  HorseModel.fromData(Map data){
    type =  data['type'];
    nameKR = data['name']['kr'];
    nameEN = data['name']['en'];
    spec = HorseSpecModel(
      speed: data['spec']['speed'],
      accel: data['spec']['accel'],
      turn: data['spec']['turn'],
      brake: data['spec']['brake'],
    );
  }
}