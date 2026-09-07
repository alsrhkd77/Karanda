import 'package:flutter/material.dart';
import 'package:karanda/enums/bdo_news_category.dart';

abstract final class AppColors {
  static const List<Color> bdoItemGradeColors = [
    Colors.grey,
    Colors.green,
    Colors.blue,
    Colors.orangeAccent,
    Colors.red,
    Colors.purple
  ];

  static const Color discordPrimary = Color.fromRGBO(88, 101, 242, 1);

  /// 파레이 소모 진행률 색상. 25% 단위로 파랑 → 초록 → 노랑 → 주황,
  /// 보유량을 다 쓰면(100% 이상) 빨강.
  static Color parleyUsageColor(double rate) {
    return switch (rate) {
      < 0.25 => Colors.blue,
      < 0.5 => Colors.green,
      < 0.75 => Colors.yellow,
      < 1.0 => Colors.orange,
      _ => Colors.red,
    };
  }

  /// 배 적재율 색상. 파랑 → 초록 → 노랑 → 주황으로 올라가고,
  /// [overloadLimit](과적 한계 적재율)을 넘으면 빨강.
  ///
  /// 한계값은 호출 측(`BarteringConstants.shipOverloadLimit`)이 넘긴다 —
  /// core 테마가 feature 상수를 참조하지 않도록.
  static Color shipLoadColor(double rate, double overloadLimit) {
    return switch (rate) {
      < 0.4 => Colors.blue,
      < 0.8 => Colors.green,
      < 1.0 => Colors.yellow,
      _ => rate < overloadLimit ? Colors.orange : Colors.red,
    };
  }

  /// 뉴스 카테고리 색상 (NOTICE=파랑, UPDATE=초록, EVENT=주황, LAB=보라)
  static Color bdoNewsCategoryColor(BdoNewsCategory category) {
    return switch (category) {
      BdoNewsCategory.notice => Colors.blue,
      BdoNewsCategory.update => Colors.green,
      BdoNewsCategory.event => Colors.orange,
      BdoNewsCategory.lab => Colors.purple,
    };
  }
}