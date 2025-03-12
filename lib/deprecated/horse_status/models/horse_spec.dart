class HorseSpec {
  late double speed;
  late double accel;
  late double turn;
  late double brake;

  HorseSpec({
    this.speed = 0.0,
    this.accel = 0.0,
    this.turn = 0.0,
    this.brake = 0.0,
  });

  HorseSpec.fromData(Map data) {
    speed = data['speed'] ?? 0.0;
    accel = data['accel'] ?? 0.0;
    turn = data['turn'] ?? 0.0;
    brake = data['brake'] ?? 0.0;
  }

  HorseSpec.fromValue(double value) {
    speed = value;
    accel = value;
    turn = value;
    brake = value;
  }

  HorseSpec operator +(HorseSpec other) => HorseSpec(
        speed: speed + other.speed,
        accel: accel + other.accel,
        turn: turn + other.turn,
        brake: brake + other.brake,
      );

  HorseSpec operator -(HorseSpec other) => HorseSpec(
        speed: speed - other.speed,
        accel: accel - other.accel,
        turn: turn - other.turn,
        brake: brake - other.brake,
      );

  HorseSpec operator /(HorseSpec other) => HorseSpec(
        speed: speed <= 0 ? 0 : speed / other.speed,
        accel: accel <= 0 ? 0 : accel / other.accel,
        turn: turn <= 0 ? 0 : turn / other.turn,
        brake: brake <= 0 ? 0 : brake / other.brake,
      );
}
