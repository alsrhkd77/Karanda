import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:karanda/model/trade_market_template.dart';

class TradeMarketDataSource {
  /// 앱이 기본 제공하는 템플릿을 에셋에서 읽는다.
  ///
  /// 에셋 형식 두 가지를 모두 받는다.
  /// - **배열**: 기존 고정 프리셋 형식(`{code, enhancement level, value}` 목록).
  ///   `value`가 산출량이므로 단가 비교형(`unitPrice`) 템플릿으로 변환한다.
  /// - **객체**: 템플릿 형식 그대로. 제작법 비교형처럼 구조가 필요한 빌트인이 쓴다.
  ///
  /// [key]가 곧 템플릿 id이자 i18n 키이며 라우트 경로가 된다.
  Future<TradeMarketTemplate> getBuiltInTemplate(String key) async {
    final data = await rootBundle.loadString("assets/data/$key.json");
    final decoded = jsonDecode(data);
    if (decoded is List) {
      return TradeMarketTemplate(
        id: key,
        name: key,
        type: TradeMarketTemplateType.unitPrice,
        items: decoded
            .map<TradeMarketTemplateItem>((item) => TradeMarketTemplateItem(
                  code: item["code"],
                  enhancementLevel: item["enhancement level"] ?? 0,
                  yieldAmount: item["value"] ?? 1,
                ))
            .toList(),
        isBuiltIn: true,
      );
    }
    return TradeMarketTemplate.fromJson(decoded, isBuiltIn: true);
  }
}
