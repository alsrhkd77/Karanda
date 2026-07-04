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