import 'dart:convert';

import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_price_data.dart';
import 'package:karanda/model/trade_market_wait_item.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';
import 'package:karanda/utils/http_status.dart';
import 'package:karanda/utils/rest_client.dart';

class TradeMarketApi {
  Future<List<TradeMarketWaitItem>> getWaitItems(BDORegion region) async {
    final List<TradeMarketWaitItem> result = [];
    final response = await RestClient.get(
      KarandaApi.tradeMarketWaitList,
      parameters: {"region": region.name},
    );
    if (response.statusCode == HttpStatus.ok) {
      for (Map json in jsonDecode(response.body)) {
        result.add(TradeMarketWaitItem.fromJson(json));
      }
    }
    return result;
  }

  Future<List<TradeMarketPriceData>> getDetailedPriceData({
    required int itemCode,
    required BDORegion region,
  }) async {
    final List<TradeMarketPriceData> result = [];
    final response = await RestClient.get(
      "/trade-market/detail",
      parameters: {
        "code": itemCode.toString(),
        "region": region.name
      },
    );
    if (response.statusCode == HttpStatus.ok) {
      for (Map json in jsonDecode(response.body)) {
        result.add(TradeMarketPriceData.fromJson(json));
      }
    }
    return result;
  }

  Future<List<TradeMarketPriceData>> getLatestPriceData({
    required List<String> items,
    required BDORegion region,
  }) async {
    final List<TradeMarketPriceData> result = [];
    final response = await RestClient.get(
      "/trade-market/latest",
      parameters: {"target_list": items, "region": region.name},
    );
    if (response.statusCode == HttpStatus.ok) {
      for (Map json in jsonDecode(response.body)) {
        result.add(TradeMarketPriceData.fromJson(json));
      }
    }
    return result;
  }
}
