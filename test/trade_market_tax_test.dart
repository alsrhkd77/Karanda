import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/model/trade_market_template.dart';

void main() {
  group('거래소 수령 비율', () {
    // 게임 사양: 수수료 35% 고정 → 기본 수령 65%.
    // 추가 수령액은 판매액이 아니라 **기본 수령액**에 곱해지고 항목끼리 합연산이다.
    test('미적용이면 판매액이 그대로 남는다', () {
      const tax = TradeMarketTaxOption();

      expect(tax.receiptRate, 1.0);
      expect(tax.receiptOf(1000), 1000);
      expect(tax.feeOf(1000), 0);
    });

    test('아무 혜택이 없으면 65%', () {
      const tax = TradeMarketTaxOption(enabled: true);

      expect(tax.receiptRate, closeTo(0.65, 1e-9));
      expect(tax.receiptOf(1000), 650);
      expect(tax.feeOf(1000), 350);
    });

    test('밸류 패키지는 기본 수령액에 +30%', () {
      const tax = TradeMarketTaxOption(enabled: true, valuePackage: true);

      // 0.65 × 1.30 = 0.845
      expect(tax.receiptRate, closeTo(0.845, 1e-9));
    });

    test('밸류 패키지와 거상의 반지는 합연산이라 +35%가 된다', () {
      const tax = TradeMarketTaxOption(
        enabled: true,
        valuePackage: true,
        merchantRing: true,
      );

      expect(tax.bonusRate, closeTo(0.35, 1e-9));
      expect(tax.receiptRate, closeTo(0.65 * 1.35, 1e-9));
    });

    test('사용자가 제시한 예시 — 밸류 패키지 + 가문 명성 7000', () {
      const tax = TradeMarketTaxOption(
        enabled: true,
        valuePackage: true,
        familyFame: 7000,
      );

      expect(tax.receiptRate, closeTo(0.65 * (1 + 0.30 + 0.015), 1e-9));
    });

    test('혜택을 모두 갖추면 합연산으로 쌓인다', () {
      const tax = TradeMarketTaxOption(
        enabled: true,
        valuePackage: true,
        merchantRing: true,
        crescentPass: true,
        familyFame: 7000,
      );

      // 0.30 + 0.05 + 0.05 + 0.015
      expect(tax.bonusRate, closeTo(0.415, 1e-9));
      expect(tax.receiptRate, closeTo(0.65 * 1.415, 1e-9));
    });
  });

  group('가문 명성 구간', () {
    test('1000 미만은 보너스가 없다', () {
      expect(TradeMarketTaxOption.familyFameBonusOf(0), 0.0);
      expect(TradeMarketTaxOption.familyFameBonusOf(999), 0.0);
    });

    test('구간 경계값을 포함한다', () {
      expect(TradeMarketTaxOption.familyFameBonusOf(1000), 0.005);
      expect(TradeMarketTaxOption.familyFameBonusOf(4000), 0.01);
      expect(TradeMarketTaxOption.familyFameBonusOf(7000), 0.015);
    });

    test('구간 사이 값은 아래 구간을 따른다', () {
      expect(TradeMarketTaxOption.familyFameBonusOf(3999), 0.005);
      expect(TradeMarketTaxOption.familyFameBonusOf(6999), 0.01);
      expect(TradeMarketTaxOption.familyFameBonusOf(99999), 0.015);
    });
  });

  group('저장·복원', () {
    test('수수료 조건이 왕복해도 값이 보존된다', () {
      const tax = TradeMarketTaxOption(
        enabled: true,
        valuePackage: true,
        crescentPass: true,
        familyFame: 4200,
      );

      final round = TradeMarketTaxOption.fromJson(tax.toJson());

      expect(round.enabled, isTrue);
      expect(round.valuePackage, isTrue);
      expect(round.merchantRing, isFalse);
      expect(round.crescentPass, isTrue);
      expect(round.familyFame, 4200);
      expect(round.receiptRate, closeTo(tax.receiptRate, 1e-9));
    });
  });
}
