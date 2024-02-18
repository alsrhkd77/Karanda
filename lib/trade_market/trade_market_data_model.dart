class TradeMarketDataModel{
  late int code;
  late int enhancementLevel;
  late int price;
  late int cumulativeVolume;
  late int currentStock;
  late DateTime date;

  TradeMarketDataModel.fromData(Map data){
    code = data['item_num'];
    enhancementLevel = data['enhancement_level'];
    price = data['price'];
    cumulativeVolume = data['cumulative_volume'];
    currentStock = data['current_stock'];
    date = DateTime.parse(data['date']);
  }
}