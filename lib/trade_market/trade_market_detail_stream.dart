import 'dart:async';
import 'dart:convert';

import 'package:karanda/common/api.dart';
import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/trade_market/market_item_model.dart';
import 'package:karanda/trade_market/trade_market_data_model.dart';
import 'package:karanda/common/http.dart' as http;

class TradeMarketDetailStream {
  final _dataStreamController = StreamController<Map<String, List<TradeMarketDataModel>>>();
  late final MarketItemModel item;

  Stream<Map<String, List<TradeMarketDataModel>>> get marketDetailData => _dataStreamController.stream;

  TradeMarketDetailStream({required this.item}){
    _getData();
  }

  Future<void> _getData() async {
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
      _dataStreamController.sink.addError(Exception(response.statusCode));
    }
    _dataStreamController.sink.add(result);
  }

  void dispose(){
    _dataStreamController.close();
  }
}