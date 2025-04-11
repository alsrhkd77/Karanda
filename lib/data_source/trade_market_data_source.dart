import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:karanda/model/trade_market_preset_item.dart';

class TradeMarketDataSource {
  Future<List<TradeMarketPresetItem>> getPresetData(String key) async {
    final List<TradeMarketPresetItem> result = [];
    final data = await rootBundle.loadString("assets/data/$key.json");
    for(Map json in jsonDecode(data)){
      result.add(TradeMarketPresetItem.fromJson(json));
    }
    return result;
  }
}