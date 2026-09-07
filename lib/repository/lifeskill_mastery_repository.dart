import 'package:karanda/data_source/lifeskill_mastery_data_source.dart';
import 'package:karanda/model/lifeskill_mastery.dart';
import 'package:karanda/model/trade_market_template.dart';

/// 생활 숙련도 구간표와 사용자 숙련도 값을 제공한다.
///
/// 구간표는 에셋에서 한 번만 읽어 캐시한다. 숙련도 값은 생활별로 하나씩만 있으면 되므로
/// 템플릿마다 다시 입력받지 않는다.
class LifeskillMasteryRepository {
  final LifeskillMasteryDataSource _dataSource;

  Map<TradeMarketLifeskill, List<LifeskillMasteryRow>>? _table;
  final Map<TradeMarketLifeskill, int> _mastery = {};

  LifeskillMasteryRepository({
    required LifeskillMasteryDataSource dataSource,
  }) : _dataSource = dataSource;

  Future<Map<TradeMarketLifeskill, List<LifeskillMasteryRow>>> _loadTable() async {
    return _table ??= await _dataSource.loadTable();
  }

  /// 사용자가 입력한 숙련도. 입력한 적 없으면 0.
  Future<int> getMastery(TradeMarketLifeskill lifeskill) async {
    if (lifeskill == TradeMarketLifeskill.none) {
      return 0;
    }
    final cached = _mastery[lifeskill];
    if (cached != null) {
      return cached;
    }
    final value = await _dataSource.getMastery(lifeskill) ?? 0;
    _mastery[lifeskill] = value;
    return value;
  }

  Future<void> setMastery(TradeMarketLifeskill lifeskill, int value) async {
    if (lifeskill == TradeMarketLifeskill.none) {
      return;
    }
    final clamped = value < 0 ? 0 : value;
    _mastery[lifeskill] = clamped;
    await _dataSource.setMastery(lifeskill, clamped);
  }

  /// 숙련도가 속한 구간을 찾는다. 표는 내림차순이므로 `숙련도 >= mastery`인 첫 항목이 정답이다.
  Future<LifeskillMasteryRow?> rowOf(
    TradeMarketLifeskill lifeskill,
    int mastery,
  ) async {
    if (lifeskill == TradeMarketLifeskill.none) {
      return null;
    }
    final table = await _loadTable();
    final rows = table[lifeskill];
    if (rows == null || rows.isEmpty) {
      return null;
    }
    for (final row in rows) {
      if (mastery >= row.mastery) {
        return row;
      }
    }
    // 표의 최저 구간보다 낮은 값은 최저 구간으로 본다.
    return rows.last;
  }

  /// 황실 납품 은화 보너스. 요리상자 납품 수익 계산에 쓴다.
  Future<double> royalTradeSilverBonusOf(
    TradeMarketLifeskill lifeskill,
    int mastery,
  ) async {
    final row = await rowOf(lifeskill, mastery);
    return row?.royalTradeSilverBonus ?? 0.0;
  }

  /// 결과물 산출 배율. 생활을 지정하지 않았으면 1.0(현행 동작).
  Future<double> outputMultiplierOf(TradeMarketLifeskill lifeskill) async {
    if (lifeskill == TradeMarketLifeskill.none) {
      return 1.0;
    }
    final mastery = await getMastery(lifeskill);
    final row = await rowOf(lifeskill, mastery);
    return row?.outputMultiplier ?? 1.0;
  }
}
