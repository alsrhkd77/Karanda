import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/web_socket_manager/web_socket_manager.dart';
import 'package:karanda/common/web_visibility/web_visibility.dart';
import 'package:karanda/trade_market/trade_market_wait_item.dart';
import 'package:karanda/common/http.dart' as http;

class TradeMarketWaitListStream {
  final _dataStreamController = StreamController<List<TradeMarketWaitItem>>.broadcast();
  List<TradeMarketWaitItem>? _data;
  /*
  final CustomWebSocketChannel _webSocketChannel = CustomWebSocketChannel(
      '${Api.marketWaitList}?token=${TokenFactory.serviceToken()}');
  StreamSubscription? _subscription;
  Timer? _timer;
  */
  DateTime? lastUpdate;

  final WebSocketManager _webSocketManager = WebSocketManager();
  final WebVisibility _webVisibility = WebVisibility();

  factory TradeMarketWaitListStream() {
    return _instance;
  }

  static final TradeMarketWaitListStream _instance =
      TradeMarketWaitListStream._internal();

  TradeMarketWaitListStream._internal() {
    //connect();
    _getLatest();
    _register();
    if(kIsWeb){
      _webVisibility.stream.listen((visible){
        if(visible){
          _getLatest();
        }
      });
    }
  }

  Stream<List<TradeMarketWaitItem>> get waitItemList =>
      _dataStreamController.stream;

  void _register() {
    _webSocketManager.register(
      destination: Api.marketWaitListChannel,
      callback: (message) {
        if (message.body != null && message.body!.isNotEmpty) {
          _parse(message.body!);
        }
      },
    );
  }

  Future<void> _getLatest() async {
    final response = await http.get(Api.marketWaitList);
    if(response.statusCode == 200){
      _parse(response.body);
    }
  }

  void _parse(String data){
    List<TradeMarketWaitItem> result = [];
    List decoded = jsonDecode(data);
    for (var data in decoded) {
      TradeMarketWaitItem item = TradeMarketWaitItem.fromData(data);
      result.add(item);
    }
    _data = result;
    _dataStreamController.sink.add(_data!);
    lastUpdate = DateTime.now();
  }

  void publish(){
    if(_data != null){
      _dataStreamController.sink.add(_data!);
    }
  }

  /*
  Future<void> connect() async {
    _subscription = _webSocketChannel.stream.listen((message) {
      List<TradeMarketWaitItem> result = [];
      if (message != null && message != '') {
        List decoded = jsonDecode(message);
        for (var data in decoded) {
          TradeMarketWaitItem item = TradeMarketWaitItem.fromData(data);
          result.add(item);
        }
        _dataStreamController.sink.add(result);
        lastUpdate = DateTime.now();
      }
    });
    _webSocketChannel.connect();
    _timer = _timer ??
        Timer.periodic(
            const Duration(seconds: 30), (timer) => _requestUpdate());
  }

  void _requestUpdate() {
    if (lastUpdate != null &&
        lastUpdate!
            .isBefore(DateTime.now().subtract(const Duration(seconds: 90)))) {
      _webSocketChannel.send('update');
    }
  }

  void disconnect() {
    _timer?.cancel();
    _timer = null;
    _webSocketChannel.disconnect();
    _subscription?.cancel();
  }

  void dispose() {
    disconnect();
    _dataStreamController.close();
  }
   */
}
