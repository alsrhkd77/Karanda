import 'dart:convert';
import 'package:convert/convert.dart' as converter;

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:karanda/trade_market/market_item_model.dart';
import 'package:karanda/trade_market/trade_market_provider.dart';

class TradeMarketNotifier with ChangeNotifier {
  final provider = TradeMarketProvider();
  List<MarketItemModel> categories = [];
  List<MarketItemModel> items = [];

  TradeMarketNotifier() {
    getData();
  }

  Future<void> getData() async {
    List data = await http
        .get(Uri.parse(
            'https://raw.githubusercontent.com/HwanSangYeonHwa/black_event/main/hammuu'))
        .then((value) => utf8.decode(converter.hex.decode(value.body)))
        .then((value) => jsonDecode(value));

    List<MarketItemModel> parsedCategories = [];
    List<MarketItemModel> parsedItems = [];
    for (Map<String, dynamic> d in data) {
      MarketItemModel item = MarketItemModel.fromJson(d);
      if (item.type == ItemType.category) {
        parsedCategories.add(item);
      } else if (item.type == ItemType.item) {
        parsedItems.add(item);
      }
    }
    categories = parsedCategories;
    items = parsedItems;
    notifyListeners();
  }

  void testApi() {
    provider.getData();
  }
}
