import 'dart:convert';

import 'package:karanda/model/trade_market_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TradeMarketTemplateDataSource {
  final String _key = "trade-market-templates";

  Future<List<TradeMarketTemplate>> load() async {
    final pref = SharedPreferencesAsync();
    final data = await pref.getString(_key);
    if (data == null) {
      return [];
    }
    final List list = jsonDecode(data);
    return list.map((item) => TradeMarketTemplate.fromJson(item)).toList();
  }

  Future<void> save(List<TradeMarketTemplate> templates) async {
    final pref = SharedPreferencesAsync();
    await pref.setString(
      _key,
      jsonEncode(templates.map((template) => template.toJson()).toList()),
    );
  }
}
