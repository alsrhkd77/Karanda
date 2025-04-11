import 'package:karanda/model/trade_market_price_data.dart';

class TradeMarketPresetItem {
  final int code;
  final int enhancementLevel;
  final int value;
  TradeMarketPriceData? price;

  TradeMarketPresetItem({
    required this.code,
    required this.enhancementLevel,
    required this.value,
  });

  String get key => "${code}_$enhancementLevel";

  factory TradeMarketPresetItem.fromJson(Map json) {
    return TradeMarketPresetItem(
      code: json["code"],
      enhancementLevel: json["enhancement level"] ?? 0,
      value: json["value"],
    );
  }
}
