import 'package:karanda/model/trade_market_preset_item.dart';
import 'package:uuid/uuid.dart';

enum TradeMarketTemplateItemRole {
  material,
  result;

  static TradeMarketTemplateItemRole fromName(String? name) {
    return TradeMarketTemplateItemRole.values.firstWhere(
      (role) => role.name == name,
      orElse: () => TradeMarketTemplateItemRole.material,
    );
  }
}

class TradeMarketTemplateItem extends TradeMarketPresetItem {
  TradeMarketTemplateItemRole role;

  TradeMarketTemplateItem({
    required super.code,
    required super.enhancementLevel,
    required super.value,
    required this.role,
  });

  factory TradeMarketTemplateItem.fromJson(Map json) {
    return TradeMarketTemplateItem(
      code: json["code"],
      enhancementLevel: json["enhancement level"] ?? 0,
      value: json["value"],
      role: TradeMarketTemplateItemRole.fromName(json["role"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "code": code,
      "enhancement level": enhancementLevel,
      "value": value,
      "role": role.name,
    };
  }
}

class TradeMarketTemplate {
  final String id;
  String name;
  List<TradeMarketTemplateItem> items;

  TradeMarketTemplate({
    String? id,
    required this.name,
    required this.items,
  }) : id = id ?? const Uuid().v7();

  List<TradeMarketTemplateItem> get materials =>
      items.where((item) => item.role == TradeMarketTemplateItemRole.material).toList();

  List<TradeMarketTemplateItem> get results =>
      items.where((item) => item.role == TradeMarketTemplateItemRole.result).toList();

  factory TradeMarketTemplate.fromJson(Map json) {
    return TradeMarketTemplate(
      id: json["id"],
      name: json["name"],
      items: (json["items"] as List)
          .map((item) => TradeMarketTemplateItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "items": items.map((item) => item.toJson()).toList(),
    };
  }
}
