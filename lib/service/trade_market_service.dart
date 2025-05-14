import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_preset_item.dart';
import 'package:karanda/model/trade_market_price_data.dart';
import 'package:karanda/model/trade_market_wait_item.dart';
import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/bdo_item_info_repository.dart';
import 'package:karanda/repository/trade_market_repository.dart';
import 'package:rxdart/rxdart.dart';

class TradeMarketService {
  final TradeMarketRepository _tradeMarketRepository;
  final AppSettingsRepository _settingsRepository;
  final BDOItemInfoRepository _itemInfoRepository;
  final _waitList = BehaviorSubject<List<TradeMarketWaitItem>>();
  StreamSubscription? _regionSubscription;

  TradeMarketService({
    required TradeMarketRepository tradeMarketRepository,
    required AppSettingsRepository settingsRepository,
    required BDOItemInfoRepository itemInfoRepository,
  })  : _tradeMarketRepository = tradeMarketRepository,
        _settingsRepository = settingsRepository,
        _itemInfoRepository = itemInfoRepository {
    _waitList.sink.addStream(_tradeMarketRepository.waitListStream);
    if (kIsWeb) {
      _waitList.onListen = _connectLiveData;
      _waitList.onCancel = _disconnectLiveData;
    } else {
      _connectLiveData();
    }
  }

  Stream<List<TradeMarketWaitItem>> get waitListStream =>
      _waitList.stream.map(_waitListItemFilter);

  void _connectLiveData() {
    if (_settingsRepository.region != null) {
      _tradeMarketRepository.getWaitItems(_settingsRepository.region!);
    }
    _regionSubscription = _settingsRepository.settingsStream
        .map((settings) => settings.region)
        .distinct()
        .listen(_onRegionUpdate);
  }

  Future<void> _disconnectLiveData() async {
    await _regionSubscription?.cancel();
    _tradeMarketRepository.disconnectLiveChannel();
  }

  void _onRegionUpdate(BDORegion region) {
    _tradeMarketRepository.disconnectLiveChannel();
    _tradeMarketRepository.connectLiveChannel(region);
  }

  List<TradeMarketWaitItem> _waitListItemFilter(
      List<TradeMarketWaitItem> items) {
    return items.where((item) {
      return _itemInfoRepository.keys.contains(item.itemCode.toString());
    }).toList();
  }

  Future<Map<String, List<TradeMarketPriceData>>> getPriceDetailData(
      String code, BDORegion region) async {
    final items = await _tradeMarketRepository.getDetailedPriceData(
      itemCode: int.parse(code),
      region: region,
    );
    final Map<String, List<TradeMarketPriceData>> result = {};
    for (TradeMarketPriceData item in items) {
      if (!result.containsKey(item.enhancementLevel.toString())) {
        result[item.enhancementLevel.toString()] = [];
      }
      result[item.enhancementLevel.toString()]!.add(item);
    }
    return result;
  }

  Future<List<TradeMarketPresetItem>> getPresetData(String key) async {
    return await _tradeMarketRepository.getPresetData(key);
  }

  Future<List<TradeMarketPriceData>> getPresetPriceData(
    List<TradeMarketPresetItem> items,
    BDORegion region,
  ) async {
    return await _tradeMarketRepository.getLatestPriceData(
      items.map((item) => "${item.code}_${item.enhancementLevel}").toList(),
      region,
    );
  }
}
