class TradeMarketWaitItem{
  late int itemCode;
  late int enhancementLevel;
  late int price;
  late DateTime targetTime;

  TradeMarketWaitItem.fromData(Map data){
    itemCode = data['item_num'] ?? data['itemNum'];
    enhancementLevel = data['enhancement_level'] ?? data['enhancementLevel'];
    price = data['price'];
    targetTime = DateTime.parse(data['target_time'] ?? data['targetTime']).toLocal();
  }

}