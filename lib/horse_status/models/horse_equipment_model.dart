import 'package:karanda/horse_status/models/horse_spec_model.dart';

class HorseEquipmentModel{
  late int code;
  late String type;
  late String nameKR;
  late String nameEN;
  int grade = 0;
  List<HorseSpecModel> _spec = [];
  //List<double> _speed = [0,0,0,0,0,0,0,0,0,0,0];
  //List<double> _accel = [0,0,0,0,0,0,0,0,0,0,0];
  //List<double> _turn = [0,0,0,0,0,0,0,0,0,0,0];
  //List<double> _brake = [0,0,0,0,0,0,0,0,0,0,0];
  int enhancementLevel = 0;

  HorseEquipmentModel.fromData(Map data){
    code = data['code'];
    type = data['type'];
    nameKR = data['name']['kr'];
    nameEN = data['name']['en'];
    grade = data['grade'];
    List<double> temp = [0,0,0,0,0,0,0,0,0,0,0];
    List<double> tempSpeed = data['spec']['speed'] ?? temp;
    List<double> tempAccel = data['spec']['accel'] ?? temp;
    List<double> tempTurn = data['spec']['turn'] ?? temp;
    List<double> tempBrake = data['spec']['brake'] ?? temp;
    for(int i =0; i<=12; i++){
      _spec.add(HorseSpecModel(
        speed: tempSpeed[i],
        accel: tempAccel[i],
        turn: tempTurn[i],
        brake: tempBrake[i],
      ));
    }
  }
}