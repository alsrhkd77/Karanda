import 'dart:convert';

import 'package:karanda/data_source/trade_market_api.dart';
import 'package:karanda/data_source/trade_market_data_source.dart';
import 'package:karanda/data_source/web_socket_manager.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_preset_item.dart';
import 'package:karanda/model/trade_market_price_data.dart';
import 'package:karanda/model/trade_market_wait_item.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class TradeMarketRepository {
  final TradeMarketApi _tradeMarketApi;
  final TradeMarketDataSource _tradeMarketDataSource;
  final WebSocketManager _webSocketManager;
  final _waitList = BehaviorSubject<List<TradeMarketWaitItem>>();

  TradeMarketRepository({
    required TradeMarketApi tradeMarketApi,
    required TradeMarketDataSource tradeMarketDataSource,
    required WebSocketManager webSocketManager,
  })  : _tradeMarketApi = tradeMarketApi,
        _tradeMarketDataSource = tradeMarketDataSource,
        _webSocketManager = webSocketManager;

  Stream<List<TradeMarketWaitItem>> get waitListStream => _waitList.stream;

  Future<void> getWaitItems(BDORegion region) async {
    final data = await _tradeMarketApi.getWaitItems(region);
    _waitList.sink.add(data);
  }

  Future<List<TradeMarketPriceData>> getDetailedPriceData({
    required int itemCode,
    required BDORegion region,
  }) async {
    return await _tradeMarketApi.getDetailedPriceData(
        itemCode: itemCode, region: region);
  }

  Future<List<TradeMarketPriceData>> getLatestPriceData(
      List<String> items, BDORegion region) async {
    return await _tradeMarketApi.getLatestPriceData(
        items: items, region: region);
  }

  void connectLiveChannel(BDORegion region) {
    _webSocketManager.register(
      destination: "/trade-market/REGION/wait-list",
      region: region,
      callback: _liveChannelCallback,
    );
  }

  void disconnectLiveChannel() {
    _webSocketManager.unregister(destination: "/trade-market/REGION/wait-list");
  }

  void _liveChannelCallback(StompFrame frame) {
    if (frame.body != null && frame.body!.isNotEmpty) {
      final List<TradeMarketWaitItem> result = [];
      for (Map json in jsonDecode(frame.body!)) {
        result.add(TradeMarketWaitItem.fromJson(json));
      }
      _waitList.sink.add(result);
    }
  }

  Future<List<TradeMarketPresetItem>> getPresetData(String key) async {
    return await _tradeMarketDataSource.getPresetData(key);
  }
}
