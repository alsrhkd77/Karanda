class ShipProfile {
  String name;
  bool useCleia; //부선장
  double totalWeight;
  double currentWeight;

  ShipProfile({
    this.name = "Ship Profile",
    this.useCleia = false,
    this.totalWeight = 20900,
    this.currentWeight = 1109,
  });

  factory ShipProfile.fromJson(Map json) {
    return ShipProfile(
      name: json["name"],
      useCleia: json["useCleia"],
      totalWeight: json["totalWeight"],
      currentWeight: json["currentWeight"],
    );
  }

  Map toJson() {
    return {
      "name": name,
      "useCleia": useCleia,
      "totalWeight": totalWeight,
      "currentWeight": currentWeight,
    };
  }
}
