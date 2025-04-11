class TradeMarketWaitItem {
  final int itemCode;
  final int enhancementLevel;
  final int price;
  final DateTime targetTime;

  TradeMarketWaitItem({
    required this.itemCode,
    required this.enhancementLevel,
    required this.price,
    required this.targetTime,
  });

  factory TradeMarketWaitItem.fromJson(Map json) {
    return TradeMarketWaitItem(
      itemCode: json['item_num'] ?? json['itemNum'],
      enhancementLevel: json['enhancement_level'] ?? json['enhancementLevel'],
      price: json['price'],
      targetTime:
          DateTime.parse(json['target_time'] ?? json['targetTime']).toLocal(),
    );
  }

  Map toJson(){
    return {
      "itemNum": itemCode,
      "enhancementLevel": enhancementLevel,
      "price": price,
      "targetTime": targetTime.toUtc().toString()
    };
  }
}
