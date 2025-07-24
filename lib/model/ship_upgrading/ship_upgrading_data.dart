import 'package:karanda/enums/ship_upgrading_data_type.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_child_data.dart';

class ShipUpgradingData {
  final int code;
  final ShipUpgradingDataType type;
  final int coin;
  final List<ShipUpgradingQuantityData> materials;
  final List<int> parent;

  ShipUpgradingData({
    required this.code,
    required this.type,
    required this.coin,
    required this.materials,
    required this.parent,
  });

  factory ShipUpgradingData.fromJson(Map json) {
    final List<ShipUpgradingQuantityData> items = [];
    for (Map item in json["materials"]) {
      items.add(ShipUpgradingQuantityData.fromJson(item));
    }
    return ShipUpgradingData(
      code: json["code"],
      type: ShipUpgradingDataType.values.byName(json["type"]),
      coin: json["coin"],
      materials: items,
      parent: List<int>.from(json["parent"]),
    );
  }
}
