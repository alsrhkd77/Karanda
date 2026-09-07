import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/service/trade_market_service.dart';

/// 메인 페이지 그리드용 템플릿 목록.
///
/// 빌트인과 사용자 템플릿을 한 목록으로 합친다. 빌트인이 항상 앞에 오고,
/// 사용자가 만든 템플릿이 뒤에 붙는다.
class TradeMarketTemplateListController extends ChangeNotifier {
  final TradeMarketService _tradeMarketService;
  late final StreamSubscription _subscription;

  List<TradeMarketTemplate> _builtIn = const [];
  List<TradeMarketTemplate>? _userTemplates;

  TradeMarketTemplateListController({
    required TradeMarketService tradeMarketService,
  }) : _tradeMarketService = tradeMarketService {
    _subscription = _tradeMarketService.templatesStream.listen((value) {
      _userTemplates = value;
      notifyListeners();
    });
    _init();
  }

  /// 빌트인 로드 전에는 null이라 화면이 로딩 상태를 유지한다.
  List<TradeMarketTemplate>? get templates {
    final user = _userTemplates;
    if (user == null) {
      return null;
    }
    return [..._builtIn, ...user];
  }

  Future<void> _init() async {
    _builtIn = await _tradeMarketService.getBuiltInTemplates();
    notifyListeners();
    // 최초 로드를 트리거해 스트림에 초기 값을 방출시킨다.
    await _tradeMarketService.getTemplates();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
