import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/bdo_item_info.dart';
import 'package:karanda/model/trade_market_price_data.dart';
import 'package:karanda/service/bdo_item_info_service.dart';
import 'package:karanda/service/trade_market_service.dart';
import 'dart:developer' as developer;

class TradeMarketDetailController extends ChangeNotifier {
  final TradeMarketService _marketService;
  final BDOItemInfoService _itemInfoService;
  final BDORegion region;
  BDOItemInfo? itemInfo;
  Map<String, List<TradeMarketPriceData>>? data;

  int selected = 0;

  TradeMarketDetailController({
    required TradeMarketService marketService,
    required BDOItemInfoService itemInfoService,
    required String code,
    required this.region,
  })  : _marketService = marketService,
        _itemInfoService = itemInfoService {
    _getItemInfo(code);
  }

  List<int> get enhancementLevels => data?.keys.map((item) => int.parse(item)).toList() ?? [];
  List<TradeMarketPriceData> get prices => data![selected.toString()]!;
  TradeMarketPriceData get latest => prices.first;
  int get maxPrice => prices.map<int>((e) => e.price).reduce(max);
  int get minPrice => prices.map<int>((e) => e.price).reduce(min);
  int get midPrice => minPrice + ((maxPrice - minPrice) / 2).round();
  int get digits => max(midPrice.toString().length - 1, 0);

  void selectItem(int value){
    if(data?.containsKey(value.toString()) ??  false){
      selected = value;
      notifyListeners();
    }
  }

  void _getItemInfo(String code){
    try {
      itemInfo = _itemInfoService.itemInfo(code);
      _getPriceData();
    } catch (e){
      developer.log("Failed to load Item info. code: $code");
      data = {};
      notifyListeners();
    }
  }

  Future<void> _getPriceData() async {
    if(itemInfo != null){
      data = await _marketService.getPriceDetailData(itemInfo!.code, region);
      for(String key in data!.keys){
        data![key]?.sort(_sort);
        data![key] = data![key]!.reversed.toList();
      }
    } else {
      data = {};
    }
    notifyListeners();
  }

  int _sort(TradeMarketPriceData a, TradeMarketPriceData b){
    return a.date.compareTo(b.date);
  }
}
