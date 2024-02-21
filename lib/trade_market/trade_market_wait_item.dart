class TradeMarketWaitItem{
  late int itemCode;
  late int enhancementLevel;
  late int price;
  late DateTime targetTime;

  TradeMarketWaitItem.fromData(Map data){
    itemCode = data['item_num'];
    enhancementLevel = data['enhancement_level'];
    price = data['price'];
    targetTime = DateTime.parse(data['target_time']).toLocal();
  }

}