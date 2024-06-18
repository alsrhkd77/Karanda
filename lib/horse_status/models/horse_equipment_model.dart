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

  HorseEquipmentModel({required this.type}){
    code = 0;
    nameKR = '선택 안함';
    nameEN = 'select';
    _spec = [HorseSpecModel()];
  }

  HorseEquipmentModel.fromData(Map data){
    code = data['code'];
    type = data['type'];
    nameKR = data['name']['kr'];
    nameEN = data['name']['en'];
    grade = data['grade'];
    List<double> temp = [0,0,0,0,0,0,0,0,0,0,0];
    List<double> tempSpeed = List<double>.from(data['spec']['speed'] ?? temp);
    List<double> tempAccel = List<double>.from(data['spec']['accel'] ?? temp);
    List<double> tempTurn = List<double>.from(data['spec']['turn'] ?? temp);
    List<double> tempBrake = List<double>.from(data['spec']['brake'] ?? temp);
    for(int i =0; i<11; i++){
      _spec.add(HorseSpecModel(
        speed: tempSpeed[i],
        accel: tempAccel[i],
        turn: tempTurn[i],
        brake: tempBrake[i],
      ));
    }
  }

  HorseSpecModel get spec => _getSpec();

  HorseSpecModel _getSpec(){
    if(_spec.length <= enhancementLevel){
      return _spec.last;
    } else {
      return _spec[enhancementLevel];
    }
  }
}