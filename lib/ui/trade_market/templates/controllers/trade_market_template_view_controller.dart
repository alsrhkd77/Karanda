import 'package:flutter/foundation.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/service/trade_market_service.dart';

class TradeMarketTemplateViewController extends ChangeNotifier {
  final TradeMarketService _tradeMarketService;
  final BDORegion region;
  final String templateId;

  TradeMarketTemplate? template;

  TradeMarketTemplateViewController({
    required TradeMarketService tradeMarketService,
    required this.templateId,
    required this.region,
  }) : _tradeMarketService = tradeMarketService {
    _getBaseData();
  }

  bool get notFound => _notFound;
  bool _notFound = false;

  bool get hasError => _hasError;
  bool _hasError = false;

  List<TradeMarketTemplateItem>? get materials => template?.materials;

  List<TradeMarketTemplateItem>? get results => template?.results;

  bool get isLoaded =>
      !(template?.items.any((item) => item.price == null) ?? true);

  int get materialsTotal => _sum(template?.materials);

  int get resultsTotal => _sum(template?.results);

  int get difference => resultsTotal - materialsTotal;

  int _sum(List<TradeMarketTemplateItem>? items) {
    if (items == null) {
      return 0;
    }
    return items.fold<int>(
      0,
      (sum, item) => sum + (item.price?.price ?? 0) * item.value,
    );
  }

  Future<void> _getBaseData() async {
    template = await _tradeMarketService.getTemplate(templateId);
    if (template == null) {
      _notFound = true;
      notifyListeners();
      return;
    }
    notifyListeners();
    _getPriceData();
  }

  Future<void> _getPriceData() async {
    final items = template?.items ?? [];
    if (items.isEmpty) {
      return;
    }
    try {
      final prices = await _tradeMarketService.getPresetPriceData(
        items,
        region,
      );
      for (TradeMarketTemplateItem item in items) {
        for (final price in prices) {
          if (price.key == item.key) {
            item.price = price;
            break;
          }
        }
      }
      _hasError = false;
      notifyListeners();
    } catch (e) {
      _hasError = true;
      notifyListeners();
    }
  }

  /// 가격 조회 실패 후 재시도한다.
  Future<void> retry() async {
    _hasError = false;
    for (final item in template?.items ?? <TradeMarketTemplateItem>[]) {
      item.price = null;
    }
    notifyListeners();
    await _getPriceData();
  }
}
