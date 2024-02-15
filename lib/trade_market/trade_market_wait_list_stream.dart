import 'dart:async';
import 'dart:convert';

import 'package:karanda/common/api.dart';
import 'package:karanda/trade_market/trade_market_wait_item.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class TradeMarketWaitListStream {
  final _dataStreamController = StreamController<List<TradeMarketWaitItem>>();
  WebSocketChannel? _channel;
  Timer? _timer;
  DateTime? _lastUpdate;

  TradeMarketWaitListStream() {
    connect();
  }

  Stream<List<TradeMarketWaitItem>> get waitItemList =>
      _dataStreamController.stream;

  Future<void> connect() async {
    _channel = WebSocketChannel.connect(Uri.parse(Api.marketWaitList));
    await _channel?.ready;
    _channel?.stream.listen(
      (message) {
        List<TradeMarketWaitItem> result = [];
        if (message != null && message != '') {
          List decoded = jsonDecode(message);
          for (var data in decoded) {
            TradeMarketWaitItem item = TradeMarketWaitItem.fromData(data);
            result.add(item);
          }
          _dataStreamController.sink.add(result);
          _lastUpdate = DateTime.now();
        }
      },
      onDone: () => print("websocket done!"),
      onError: (e) => print("websocket error!"),
    );
    _timer = Timer.periodic(
        const Duration(seconds: 30), (timer) => _requestUpdate());
  }

  void _requestUpdate() {
    if (_lastUpdate != null &&
        _lastUpdate!
            .isBefore(DateTime.now().subtract(const Duration(seconds: 90)))) {
      _channel?.sink.add('update');
      _timer?.cancel();
      _timer = Timer.periodic(
          const Duration(seconds: 30), (timer) => _requestUpdate());
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _channel?.sink.close(status.goingAway);
    _channel = null;
    _dataStreamController.close();
  }
}
