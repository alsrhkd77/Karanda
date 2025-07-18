import 'package:karanda/model/ship_upgrading/ship_upgrading_child_data.dart';

class ShipUpgradingSettings {
  int selected = 49029;
  final List<ShipUpgradingQuantityData> dailyQuest = [
    ShipUpgradingQuantityData(code: 5807, count: 2),
    ShipUpgradingQuantityData(code: 5814, count: 10),
    ShipUpgradingQuantityData(code: 5829, count: 6),
    ShipUpgradingQuantityData(code: 5832, count: 0),
    ShipUpgradingQuantityData(code: 5820, count: 2),
    ShipUpgradingQuantityData(code: 5822, count: 3),
    ShipUpgradingQuantityData(code: 5824, count: 3),
    ShipUpgradingQuantityData(code: 5827, count: 20),
    ShipUpgradingQuantityData(code: 5810, count: 5),
    ShipUpgradingQuantityData(code: 5828, count: 8),
    ShipUpgradingQuantityData(code: 5823, count: 1),
    ShipUpgradingQuantityData(code: 5830, count: 0),
    ShipUpgradingQuantityData(code: 5812, count: 2),
    ShipUpgradingQuantityData(code: 5809, count: 2),
    ShipUpgradingQuantityData(code: 5821, count: 2),
    ShipUpgradingQuantityData(code: 5815, count: 2),
    ShipUpgradingQuantityData(code: 5831, count: 2),
  ];

  ShipUpgradingSettings({
    int? selected,
    List<ShipUpgradingQuantityData>? dailyQuest,
  }) {
    this.selected = selected ?? this.selected;
    for (ShipUpgradingQuantityData child in dailyQuest ?? []) {
      final index = this.dailyQuest.indexWhere((item) {
        return item.code == child.code;
      });
      if (index < 0) {
        this.dailyQuest.add(child);
      } else {
        this.dailyQuest[index].count = child.count;
      }
    }
  }

  factory ShipUpgradingSettings.fromJson(Map json) {
    final List<ShipUpgradingQuantityData> items = [];
    for (Map data in json["dailyQuest"] ?? []) {
      items.add(ShipUpgradingQuantityData.fromJson(data));
    }
    return ShipUpgradingSettings(selected: json["selected"], dailyQuest: items);
  }

  Map toJson() {
    return {
      "selected": selected,
      "dailyQuest": dailyQuest.map((item) => item.toJson()).toList(),
    };
  }
}
