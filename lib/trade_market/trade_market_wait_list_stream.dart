import 'dart:async';
import 'dart:convert';

import 'package:karanda/common/api.dart';
import 'package:karanda/common/custom_web_socket_channel/custom_web_socket_channel.dart';
import 'package:karanda/common/token_factory.dart';
import 'package:karanda/trade_market/trade_market_wait_item.dart';

class TradeMarketWaitListStream {
  final _dataStreamController = StreamController<List<TradeMarketWaitItem>>();
  final CustomWebSocketChannel _webSocketChannel = CustomWebSocketChannel('${Api.marketWaitList}?token=${TokenFactory.serviceToken()}');
  StreamSubscription? _subscription;
  Timer? _timer;
  DateTime? lastUpdate;

  TradeMarketWaitListStream() {
    connect();
  }

  Stream<List<TradeMarketWaitItem>> get waitItemList =>
      _dataStreamController.stream;

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
}
