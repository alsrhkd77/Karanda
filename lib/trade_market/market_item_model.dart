enum ItemType { category, item }

class MarketItemModel {
  late ItemType type;
  late String num;
  late String name;

  MarketItemModel.fromJson(Map<String, dynamic> json) {
    type = ItemType.values.byName(json['type'].toLowerCase());
    num = json['num'];
    name = json['name'];
  }
}
