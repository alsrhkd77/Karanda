import 'package:flutter/foundation.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_preset_item.dart';
import 'package:karanda/service/trade_market_service.dart';

class TradeMarketPresetController extends ChangeNotifier {
  final TradeMarketService _tradeMarketService;
  final BDORegion region;
  final String key;

  List<TradeMarketPresetItem>? items;

  TradeMarketPresetController({
    required TradeMarketService tradeMarketService,
    required this.key,
    required this.region,
  }) : _tradeMarketService = tradeMarketService {
    _getBaseData();
  }

  bool get isLoaded => !(items?.any((item) => item.price == null) ?? true);

  Future<void> _getBaseData() async {
    items = await _tradeMarketService.getPresetData(key);
    notifyListeners();
    if (items != null) {
      _getPriceData();
    }
  }

  Future<void> _getPriceData() async {
    if (items?.isNotEmpty ?? false) {
      final prices = await _tradeMarketService.getPresetPriceData(
        items!,
        region,
      );
      for (TradeMarketPresetItem item in items!) {
        item.price = prices.firstWhere((price) => price.key == item.key);
      }
      items?.sort(_sortByPriceData);
      notifyListeners();
    }
  }

  int _sortByPriceData(TradeMarketPresetItem a, TradeMarketPresetItem b) {
    if (a.price == null && b.price == null) {
      return 0;
    } else if (b.price == null) {
      return 1;
    } else if (a.price == null) {
      return -1;
    }

    if ((a.price!.currentStock > 0 && b.price!.currentStock > 0) ||
        (a.price!.currentStock == 0 && b.price!.currentStock == 0)) {
      return (a.price!.price / a.value).compareTo(b.price!.price / b.value);
    }
    return b.price!.currentStock.compareTo(a.price!.currentStock);
  }
}
