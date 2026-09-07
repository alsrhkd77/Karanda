import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/data_source/lifeskill_mastery_data_source.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/repository/lifeskill_mastery_repository.dart';

/// 실제 에셋(`assets/data/lifeskill_mastery.json`)을 읽어 구간 조회 규칙을 확인한다.
/// 표가 갱신될 때 조회 계약이 깨지지 않도록 잡아 두는 테스트다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repository =
      LifeskillMasteryRepository(dataSource: LifeskillMasteryDataSource());

  group('숙련도 구간 조회', () {
    test('구간 경계값은 해당 구간을 쓴다', () async {
      final row =
          await repository.rowOf(TradeMarketLifeskill.cooking, 3000);

      expect(row?.mastery, 3000);
      expect(row?.productAmountIncrease, closeTo(0.7645, 1e-6));
    });

    test('구간 사이 값은 아래 구간을 따른다', () async {
      final row = await repository.rowOf(TradeMarketLifeskill.cooking, 1849);

      expect(row?.mastery, 1800);
    });

    test('산출 배율은 1 + 수량 증가율이다', () async {
      final row = await repository.rowOf(TradeMarketLifeskill.cooking, 1200);

      expect(row?.productAmountIncrease, closeTo(0.244, 1e-6));
      expect(row?.outputMultiplier, closeTo(1.244, 1e-6));
    });

    test('가공은 최저 구간이 0이라 숙련도 0에서도 조회된다', () async {
      final row = await repository.rowOf(TradeMarketLifeskill.processing, 0);

      expect(row, isNotNull);
      expect(row?.mastery, 0);
      expect(row?.extra["materials count"], 10);
    });

    test('연금의 희귀 아이템 확률은 2000 초과에서도 0이 아니다', () async {
      // 원본 자료의 공백을 2000 구간 값으로 채워 뒀다. 0으로 되돌아가면 과소 계산된다.
      final high = await repository.rowOf(TradeMarketLifeskill.alchemy, 3000);
      final base = await repository.rowOf(TradeMarketLifeskill.alchemy, 2000);

      expect(high?.extra["rare item chance"], base?.extra["rare item chance"]);
      expect(high?.extra["rare item chance"], greaterThan(0));
    });

    test('생활을 지정하지 않으면 배율이 1.0이다', () async {
      final multiplier =
          await repository.outputMultiplierOf(TradeMarketLifeskill.none);

      expect(multiplier, 1.0);
    });

    test('요리와 연금의 황납 은화 보너스는 같은 값이다', () async {
      final cooking = await repository.rowOf(TradeMarketLifeskill.cooking, 1200);
      final alchemy = await repository.rowOf(TradeMarketLifeskill.alchemy, 1200);

      expect(cooking?.royalTradeSilverBonus, alchemy?.royalTradeSilverBonus);
      expect(cooking?.royalTradeSilverBonus, closeTo(0.9293, 1e-6));
    });
  });
}
