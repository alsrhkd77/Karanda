class TradeMarketPriceData {
  final int itemCode;
  final int enhancementLevel;
  final int price;
  final int cumulativeVolume;
  final int currentStock;
  final DateTime date;

  TradeMarketPriceData({
    required this.itemCode,
    required this.enhancementLevel,
    required this.price,
    required this.cumulativeVolume,
    required this.currentStock,
    required this.date,
  });

  String get key => "${itemCode}_$enhancementLevel";

  factory TradeMarketPriceData.fromJson(Map json) {
    return TradeMarketPriceData(
      itemCode: json['item_num'] ?? json['itemNum'],
      enhancementLevel: json['enhancement_level'] ?? json['enhancementLevel'],
      price: json['price'],
      cumulativeVolume: json['cumulative_volume'] ?? json['cumulativeVolume'],
      currentStock: json['current_stock'] ?? json['currentStock'],
      date: DateTime.parse(json['date']),
    );
  }
}
