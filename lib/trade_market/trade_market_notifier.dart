import 'dart:collection';
import 'dart:convert';
import 'package:convert/convert.dart' as converter;
import 'package:flutter/services.dart';

import 'package:flutter/widgets.dart';
import 'package:karanda/trade_market/market_item_model.dart';

class TradeMarketNotifier with ChangeNotifier {
  SplayTreeMap<String, MarketItemModel> itemInfo = SplayTreeMap();

  SplayTreeMap<String, String> itemNames = SplayTreeMap();

  List<MarketItemModel> categories = [];
  List<MarketItemModel> items = [];

  TradeMarketNotifier() {
    getData();
  }

  Future<void> getData() async {
    var data = await rootBundle.loadString('assets/Hammuu')
        .then((value) => utf8.decode(converter.hex.decode(value)))
        .then((value) => value.split('\n'));
    String ver = data.first;
    String splitPattern = ver.characters.last;
    ver = ver.replaceAll(splitPattern, '');
    data.removeAt(0);
    SplayTreeMap<String, MarketItemModel> itemDataMap = SplayTreeMap();
    for (String line in data) {
      MarketItemModel item = MarketItemModel.fromStringData(line, splitPattern);
      itemDataMap[item.code] = item;
    }
    itemInfo = itemDataMap;
    itemNames = SplayTreeMap.fromIterable(
      itemInfo.values.where((item) => item.tradeAble),
      key: (element) => element.name,
      value: (element) => element.code,
    );
    notifyListeners();
  }
}
