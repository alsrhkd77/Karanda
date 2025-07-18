class ShipUpgradingQuantityData {
  final int code;
  int count;

  ShipUpgradingQuantityData({required this.code, required this.count});

  factory ShipUpgradingQuantityData.fromJson(Map json) {
    return ShipUpgradingQuantityData(code: json["code"], count: json["count"]);
  }

  Map toJson() {
    return {"code": code, "count": count};
  }
}
