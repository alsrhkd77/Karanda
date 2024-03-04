import 'dart:convert';

import 'package:karanda/common/api.dart';
import 'package:karanda/common/http.dart' as http;
import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/trade_market/market_item_model.dart';
import 'package:karanda/trade_market/trade_market_data_model.dart';

class TradeMarketProvider {
  static Future<Map<String, List<TradeMarketDataModel>>> getDetail(MarketItemModel item) async {
    Map<String, List<TradeMarketDataModel>> result = {};
    final response = await http.get('${Api.marketItemDetail}/${item.code}');
    if (response.statusCode == 200) {
      for (Map data in jsonDecode(response.bodyUTF)) {
        TradeMarketDataModel dataModel = TradeMarketDataModel.fromData(data);
        String key = item.enhancementLevelToString(dataModel.enhancementLevel);
        if(!result.containsKey(key)){
          result[key] = [];
        }
        result[key]!.add(dataModel);
      }
      for(String key in result.keys){
        result[key]!.sort((a, b) => b.date.compareTo(a.date));
      }
    } else {
      return Future.error(Exception(response.statusCode));
    }
    return result;
  }

  static Future<List<TradeMarketDataModel>> getLatest(Map<String, List<String>> items) async {
    String param = '';
    for(String key in items.keys){
      if(items[key] == null) continue;
      for(String enhancement in items[key]!){
        if(param.isNotEmpty){
          param = '$param&target_list=';
        }
        param = '$param${key}_$enhancement';
      }
    }
    final response = await http.get('${Api.marketItemLatest}?target_list=$param');
    if(response.statusCode == 200){
      List<TradeMarketDataModel> result = [];
      for (Map data in jsonDecode(response.bodyUTF)) {
        TradeMarketDataModel dataModel = TradeMarketDataModel.fromData(data);
        result.add(dataModel);
      }
      return result;
    }
    return [];
  }
}
