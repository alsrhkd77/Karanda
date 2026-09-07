import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_price_data.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/ui/trade_market/templates/controllers/trade_market_template_view_controller.dart';

import 'support/fake_trade_market_service.dart';

TradeMarketPriceData _price(
  int code,
  int price, {
  int stock = 10,
  int enhancementLevel = 0,
}) {
  return TradeMarketPriceData(
    itemCode: code,
    enhancementLevel: enhancementLevel,
    price: price,
    cumulativeVolume: 0,
    currentStock: stock,
    date: DateTime(2026, 8, 17),
  );
}

Future<TradeMarketTemplateViewController> _load(
  FakeTradeMarketService service,
  String id,
) async {
  final controller = TradeMarketTemplateViewController(
    tradeMarketService: service,
    templateId: id,
    region: BDORegion.KR,
  );
  // 생성자에서 시작한 로드와 가격 조회가 끝나기를 기다린다.
  await Future.delayed(Duration.zero);
  await Future.delayed(Duration.zero);
  return controller;
}

void main() {
  group('단가 비교형 정렬', () {
    // 산출량이 다르므로 "가격이 싼 순"과 "단가가 싼 순"이 뒤집히는 구성이다.
    final template = TradeMarketTemplate(
      id: 'unit',
      name: 'unit',
      type: TradeMarketTemplateType.unitPrice,
      items: [
        TradeMarketTemplateItem(code: 1, yieldAmount: 1),
        TradeMarketTemplateItem(code: 2, yieldAmount: 5),
        TradeMarketTemplateItem(code: 3, yieldAmount: 25),
      ],
    );

    test('가격이 아니라 산출 1개당 단가로 정렬한다', () async {
      final service = FakeTradeMarketService(
        templates: {'unit': template},
        prices: {
          '1_0': _price(1, 100), // 단가 100
          '2_0': _price(2, 300), // 단가 60
          '3_0': _price(3, 1000), // 단가 40
        },
      );

      final controller = await _load(service, 'unit');
      final order = controller.sortedByUnitPrice.map((e) => e.code).toList();

      expect(order, [3, 2, 1]);
      expect(controller.unitPriceOf(controller.items[0]), 100);
      expect(controller.unitPriceOf(controller.items[2]), 40);
    });

    test('재고가 없는 항목은 단가가 싸도 뒤로 밀린다', () async {
      final service = FakeTradeMarketService(
        templates: {'unit': template},
        prices: {
          '1_0': _price(1, 100),
          '2_0': _price(2, 300),
          '3_0': _price(3, 1000, stock: 0), // 단가는 최저지만 품절
        },
      );

      final controller = await _load(service, 'unit');
      final order = controller.sortedByUnitPrice.map((e) => e.code).toList();

      expect(order, [2, 1, 3]);
      expect(controller.inStock(controller.items[2]), isFalse);
    });
  });

  group('준비물 총액형', () {
    test('수량을 곱한 합계를 낸다', () async {
      final service = FakeTradeMarketService(
        templates: {
          'list': TradeMarketTemplate(
            id: 'list',
            name: 'list',
            type: TradeMarketTemplateType.shoppingList,
            items: [
              TradeMarketTemplateItem(code: 1, quantity: 3),
              TradeMarketTemplateItem(code: 2, quantity: 10),
            ],
          ),
        },
        prices: {'1_0': _price(1, 100), '2_0': _price(2, 50)},
      );

      final controller = await _load(service, 'list');

      expect(controller.total, 3 * 100 + 10 * 50);
    });
  });

  group('차익형', () {
    test('결과물 합계에서 재료 합계를 뺀다', () async {
      final service = FakeTradeMarketService(
        templates: {
          'profit': TradeMarketTemplate(
            id: 'profit',
            name: 'profit',
            type: TradeMarketTemplateType.profit,
            items: [
              TradeMarketTemplateItem(
                code: 1,
                quantity: 2,
                role: TradeMarketTemplateItemRole.material,
              ),
              TradeMarketTemplateItem(
                code: 2,
                quantity: 1,
                role: TradeMarketTemplateItemRole.result,
              ),
            ],
          ),
        },
        prices: {'1_0': _price(1, 100), '2_0': _price(2, 500)},
      );

      final controller = await _load(service, 'profit');

      expect(controller.materialsTotal, 200);
      expect(controller.resultsTotal, 500);
      expect(controller.difference, 300);
      // 수수료 계산은 별도 단계에서 붙는다. 지금은 미적용이 기본이다.
      expect(controller.taxApplied, isFalse);
    });
  });

  group('가격 조회', () {
    test('구성 요소까지 모아 배치 한 번으로 조회한다', () async {
      final service = FakeTradeMarketService(
        templates: {
          'derived': TradeMarketTemplate(
            id: 'derived',
            name: 'derived',
            type: TradeMarketTemplateType.shoppingList,
            items: [
              TradeMarketTemplateItem(code: 1, quantity: 1),
              TradeMarketTemplateItem(
                source: TradeMarketItemSource.derived,
                customName: '황혼의 보석',
                quantity: 1,
                components: [
                  TradeMarketTemplateItem(code: 2, quantity: 100),
                  TradeMarketTemplateItem(code: 3, quantity: 20000),
                ],
              ),
              TradeMarketTemplateItem(
                source: TradeMarketItemSource.offMarket,
                customName: '태초의 불꽃',
                quantity: 1,
                offMarketPrice: 7,
              ),
            ],
          ),
        },
        prices: {
          '1_0': _price(1, 10),
          '2_0': _price(2, 5),
          '3_0': _price(3, 2),
        },
      );

      final controller = await _load(service, 'derived');

      expect(service.priceCallCount, 1);
      expect(service.lastRequestedKeys, containsAll(['1_0', '2_0', '3_0']));
      // offMarket 아이템은 조회 대상이 아니다.
      expect(service.lastRequestedKeys.length, 3);
      expect(controller.total, 10 + (100 * 5 + 20000 * 2) + 7);
    });

    test('조회 실패는 에러 상태로 잡아 재시도할 수 있게 한다', () async {
      final service = FakeTradeMarketService(
        templates: {
          'fail': TradeMarketTemplate(
            id: 'fail',
            name: 'fail',
            items: [TradeMarketTemplateItem(code: 1)],
          ),
        },
      )..throwOnPriceRequest = true;

      final controller = await _load(service, 'fail');

      expect(controller.hasError, isTrue);
    });
  });

  test('없는 id면 notFound로 표시한다', () async {
    final controller = await _load(FakeTradeMarketService(), 'missing');

    expect(controller.notFound, isTrue);
  });

  group('수수료·숙련도 반영', () {
    TradeMarketTemplate profitTemplate(TradeMarketTaxOption tax,
        {TradeMarketLifeskill lifeskill = TradeMarketLifeskill.none}) {
      return TradeMarketTemplate(
        id: 'tax',
        name: 'tax',
        type: TradeMarketTemplateType.profit,
        tax: tax,
        lifeskill: lifeskill,
        items: [
          TradeMarketTemplateItem(
            code: 1,
            quantity: 1,
            role: TradeMarketTemplateItemRole.material,
          ),
          TradeMarketTemplateItem(
            code: 2,
            quantity: 1,
            role: TradeMarketTemplateItemRole.result,
          ),
        ],
      );
    }

    FakeTradeMarketService serviceWith(TradeMarketTemplate template) {
      return FakeTradeMarketService(
        templates: {'tax': template},
        prices: {'1_0': _price(1, 400), '2_0': _price(2, 1000)},
      );
    }

    test('수수료 미적용이면 기존 수치가 그대로 유지된다', () async {
      final controller = await _load(
        serviceWith(profitTemplate(const TradeMarketTaxOption())),
        'tax',
      );

      expect(controller.resultsTotal, 1000);
      expect(controller.marketFee, 0);
      expect(controller.difference, 600);
      expect(controller.differenceBeforeTax, 600);
    });

    test('수수료를 적용하면 결과물이 아니라 차익이 줄어든다', () async {
      final controller = await _load(
        serviceWith(profitTemplate(
          const TradeMarketTaxOption(enabled: true, valuePackage: true),
        )),
        'tax',
      );

      // 판매액 1000 → 수령 845
      expect(controller.resultsTotal, 1000);
      expect(controller.resultsReceipt, 845);
      expect(controller.marketFee, 155);
      expect(controller.difference, 445);
      // 세전 차익은 그대로 병기된다.
      expect(controller.differenceBeforeTax, 600);
    });

    test('숙련도 배율은 결과물에만 곱해진다', () async {
      final service = serviceWith(profitTemplate(
        const TradeMarketTaxOption(),
        lifeskill: TradeMarketLifeskill.cooking,
      ));
      service.mastery[TradeMarketLifeskill.cooking] = 1800;
      service.multipliers[TradeMarketLifeskill.cooking] = 1.5;

      final controller = await _load(service, 'tax');

      expect(controller.mastery, 1800);
      expect(controller.outputMultiplier, 1.5);
      expect(controller.resultsTotal, 1500);
      // 재료비는 배율의 영향을 받지 않는다.
      expect(controller.materialsTotal, 400);
      expect(controller.difference, 1100);
    });

    test('숙련도 배율과 수수료가 함께 적용된다', () async {
      final service = serviceWith(profitTemplate(
        const TradeMarketTaxOption(enabled: true, valuePackage: true),
        lifeskill: TradeMarketLifeskill.cooking,
      ));
      service.multipliers[TradeMarketLifeskill.cooking] = 1.5;

      final controller = await _load(service, 'tax');

      expect(controller.resultsTotal, 1500);
      expect(controller.resultsReceipt, (1500 * 0.845).round());
    });
  });
}
