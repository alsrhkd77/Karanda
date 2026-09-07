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

  /// 차트에 보여줄 기간(일). 서버가 90일치를 주므로 그보다 크게 잡지 않는다.
  static const List<int> periodOptions = [7, 30, 90];
  int period = 90;

  TradeMarketDetailController({
    required TradeMarketService marketService,
    required BDOItemInfoService itemInfoService,
    required String code,
    required this.region,
  })  : _marketService = marketService,
        _itemInfoService = itemInfoService {
    _getItemInfo(code);
  }

  List<int> get enhancementLevels =>
      data?.keys.map((item) => int.parse(item)).toList() ?? [];

  List<TradeMarketPriceData> get prices => data![selected.toString()]!;

  /// 선택한 기간만큼 자른 가격 이력.
  /// 목록은 최신이 앞이므로(`first = 최신`) 앞에서부터 잘라야 최근 구간이 남는다.
  List<TradeMarketPriceData> get pricesInPeriod {
    final all = prices;
    return all.length <= period ? all : all.sublist(0, period);
  }

  TradeMarketPriceData get latest => prices.first;

  /// 차트 축 계산은 화면에 실제로 그리는 구간만 본다.
  List<TradeMarketPriceData> get _chartSource =>
      pricesInPeriod.isEmpty ? prices : pricesInPeriod;

  int get maxPrice => _chartSource.map<int>((e) => e.price).reduce(max);
  int get minPrice => _chartSource.map<int>((e) => e.price).reduce(min);
  int get midPrice => minPrice + ((maxPrice - minPrice) / 2).round();
  int get digits => max(midPrice.toString().length - 1, 0);

  void selectItem(int value) {
    if (data?.containsKey(value.toString()) ?? false) {
      selected = value;
      notifyListeners();
    }
  }

  void selectPeriod(int value) {
    if (period == value) {
      return;
    }
    period = value;
    notifyListeners();
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
      // 0단계가 없는 아이템도 있으므로 첫 강화 단계를 실제 데이터에서 고른다.
      final levels = enhancementLevels;
      if (levels.isNotEmpty && !levels.contains(selected)) {
        selected = levels.first;
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
