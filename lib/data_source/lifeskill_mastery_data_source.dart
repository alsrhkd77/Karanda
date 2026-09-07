import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:karanda/model/lifeskill_mastery.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 생활 숙련도 구간표(에셋)와 사용자가 입력한 숙련도 값(로컬 저장)을 다룬다.
class LifeskillMasteryDataSource {
  static const String _assetPath = "assets/data/lifeskill_mastery.json";

  /// 생활별 사용자 숙련도 저장 키.
  String _key(TradeMarketLifeskill lifeskill) =>
      "lifeskill_mastery_${lifeskill.name}";

  /// 구간표를 생활별로 읽는다. 표는 mastery 내림차순으로 정렬돼 있다.
  Future<Map<TradeMarketLifeskill, List<LifeskillMasteryRow>>> loadTable() async {
    final data = await rootBundle.loadString(_assetPath);
    final Map json = jsonDecode(data);
    final result = <TradeMarketLifeskill, List<LifeskillMasteryRow>>{};
    for (final lifeskill in TradeMarketLifeskill.values) {
      if (lifeskill == TradeMarketLifeskill.none) {
        continue;
      }
      final rows = json[lifeskill.name];
      if (rows is! List) {
        continue;
      }
      result[lifeskill] =
          rows.map((row) => LifeskillMasteryRow.fromJson(row)).toList();
    }
    return result;
  }

  /// 요리상자가 리뉴얼 전에 쓰던 숙련도 키. 값을 잃지 않도록 한 번만 이어받는다.
  static const String _legacyCookingKey = "cooking_box_user_proficiency";

  Future<int?> getMastery(TradeMarketLifeskill lifeskill) async {
    final pref = SharedPreferencesAsync();
    final value = await pref.getInt(_key(lifeskill));
    if (value != null) {
      return value;
    }
    if (lifeskill == TradeMarketLifeskill.cooking) {
      final legacy = await pref.getInt(_legacyCookingKey);
      if (legacy != null) {
        await pref.setInt(_key(lifeskill), legacy);
        return legacy;
      }
    }
    return null;
  }

  Future<void> setMastery(TradeMarketLifeskill lifeskill, int value) async {
    final pref = SharedPreferencesAsync();
    await pref.setInt(_key(lifeskill), value);
  }
}
