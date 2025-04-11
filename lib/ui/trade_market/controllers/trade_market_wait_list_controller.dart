import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/model/trade_market_wait_item.dart';
import 'package:karanda/repository/time_repository.dart';
import 'package:karanda/service/trade_market_service.dart';

class TradeMarketWaitListController extends ChangeNotifier {
  final TradeMarketService _marketService;
  final TimeRepository _timeRepository;
  late final StreamSubscription _now;
  late final StreamSubscription _items;

  List<TradeMarketWaitItem>? items;
  DateTime now = DateTime.now();

  TradeMarketWaitListController({
    required TradeMarketService marketService,
    required TimeRepository timeRepository,
  })  : _marketService = marketService,
        _timeRepository = timeRepository {
    _now = _timeRepository.realTimeStream.listen(_onTimeUpdate);
    _items = _marketService.waitListStream.listen(_onDataUpdate);
  }

  void _onDataUpdate(List<TradeMarketWaitItem> value) {
    items = value;
    notifyListeners();
  }

  void _onTimeUpdate(DateTime value) {
    now = value;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _items.cancel();
    await _now.cancel();
    super.dispose();
  }
}
