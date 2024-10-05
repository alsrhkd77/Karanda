class TradeMarketDataModel{
  late int code;
  late int enhancementLevel;
  late int price;
  late int cumulativeVolume;
  late int currentStock;
  late DateTime date;

  TradeMarketDataModel.fromData(Map data){
    code = data['item_num'] ?? data['itemNum'];
    enhancementLevel = data['enhancement_level'] ?? data['enhancementLevel'];
    price = data['price'];
    cumulativeVolume = data['cumulative_volume'] ?? data['cumulativeVolume'];
    currentStock = data['current_stock'] ?? data['currentStock'];
    date = DateTime.parse(data['date']);
  }
}