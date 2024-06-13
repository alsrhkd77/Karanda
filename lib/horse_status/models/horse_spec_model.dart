class HorseSpecModel {
  int level = 0;
  late double speed;
  late double accel;
  late double turn;
  late double brake;

  HorseSpecModel({
    this.speed = 0,
    this.accel = 0,
    this.turn = 0,
    this.brake = 0,
  });

  HorseSpecModel.fromData(Map data){
    speed = data['speed'] ?? 0;
    accel = data['accel'] ?? 0;
    turn = data['turn'] ?? 0;
    brake = data['brake'] ?? 0;
  }
}
