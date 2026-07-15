import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/service/trade_market_service.dart';

class TradeMarketTemplateListController extends ChangeNotifier {
  final TradeMarketService _tradeMarketService;
  late final StreamSubscription _subscription;

  List<TradeMarketTemplate>? templates;

  TradeMarketTemplateListController({
    required TradeMarketService tradeMarketService,
  }) : _tradeMarketService = tradeMarketService {
    _subscription = _tradeMarketService.templatesStream.listen((value) {
      templates = value;
      notifyListeners();
    });
    // 최초 로드를 트리거해 스트림에 초기 값을 방출시킨다.
    _tradeMarketService.getTemplates();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
