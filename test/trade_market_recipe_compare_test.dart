import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/data_source/caphras_requirement_data_source.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_price_data.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/repository/caphras_requirement_repository.dart';
import 'package:karanda/ui/trade_market/templates/controllers/trade_market_template_view_controller.dart';

import 'support/fake_trade_market_service.dart';

TradeMarketPriceData _price(int code, int price, {int stock = 10}) {
  return TradeMarketPriceData(
    itemCode: code,
    enhancementLevel: 0,
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
  for (var i = 0; i < 4; i++) {
    await Future.delayed(Duration.zero);
  }
  return controller;
}

/// 제작법 하나를 만든다.
TradeMarketRecipeVariant _variant(
  String name,
  List<TradeMarketTemplateItem> items,
) {
  return TradeMarketRecipeVariant(name: name, items: items);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('제작법 비교', () {
    TradeMarketTemplate compareTemplate() {
      return TradeMarketTemplate(
        id: 'compare',
        name: 'compare',
        type: TradeMarketTemplateType.recipeCompare,
        variants: [
          _variant('A', [TradeMarketTemplateItem(code: 1, quantity: 2)]),
          _variant('B', [TradeMarketTemplateItem(code: 2, quantity: 1)]),
          _variant('C', [
            TradeMarketTemplateItem(code: 1, quantity: 1),
            TradeMarketTemplateItem(code: 2, quantity: 1),
          ]),
        ],
      );
    }

    test('제작법별 총 원가를 각각 계산한다', () async {
      final service = FakeTradeMarketService(
        templates: {'compare': compareTemplate()},
        prices: {'1_0': _price(1, 100), '2_0': _price(2, 150)},
      );

      final controller = await _load(service, 'compare');

      expect(controller.variantTotal(controller.variants[0]), 200);
      expect(controller.variantTotal(controller.variants[1]), 150);
      expect(controller.variantTotal(controller.variants[2]), 250);
    });

    test('최저가 제작법을 고르고 차액을 낸다', () async {
      final service = FakeTradeMarketService(
        templates: {'compare': compareTemplate()},
        prices: {'1_0': _price(1, 100), '2_0': _price(2, 150)},
      );

      final controller = await _load(service, 'compare');

      expect(controller.cheapestVariant?.name, 'B');
      expect(controller.variantExtraCost(controller.variants[1]), 0);
      expect(controller.variantExtraCost(controller.variants[0]), 50);
      expect(controller.variantExtraCost(controller.variants[2]), 100);
    });

    test('제작법의 모든 아이템을 배치 한 번으로 조회한다', () async {
      final service = FakeTradeMarketService(
        templates: {'compare': compareTemplate()},
        prices: {'1_0': _price(1, 100), '2_0': _price(2, 150)},
      );

      await _load(service, 'compare');

      expect(service.priceCallCount, 1);
      expect(service.lastRequestedKeys.toSet(), {'1_0', '2_0'});
    });

    test('가격을 모르는 제작법은 최저가 판정에서 빠진다', () async {
      final service = FakeTradeMarketService(
        templates: {'compare': compareTemplate()},
        // 2번 아이템 가격이 없어 B·C는 계산 불가.
        prices: {'1_0': _price(1, 100)},
      );

      final controller = await _load(service, 'compare');

      expect(controller.variantTotal(controller.variants[1]), isNull);
      expect(controller.cheapestVariant?.name, 'A');
    });
  });

  group('카프라스 요구량 에셋', () {
    final repository =
        CaphrasRequirementRepository(dataSource: CaphrasRequirementDataSource());

    test('우두머리 주무기는 동(Ⅴ)에서 29,403개가 필요하다', () async {
      final count = await repository.countOf(
        code: 10010, // 크자카 장검
        mainCategory: 1,
        name: '크자카 장검',
        enhancementLevel: 20,
      );

      expect(count, 29403);
    });

    test('오핀도 크자카와 같은 그룹으로 판정된다', () async {
      final count = await repository.countOf(
        code: 10086,
        mainCategory: 1,
        name: '오핀 테트의 빛 장검',
        enhancementLevel: 20,
      );

      expect(count, 29403);
    });

    test('각성무기는 주무기와 값이 다르다', () async {
      final count = await repository.countOf(
        code: 14702, // 단델리온 대검
        mainCategory: 10,
        name: '단델리온 대검',
        enhancementLevel: 20,
      );

      expect(count, 33768);
    });

    test('우둔한 나무 정령의 갑옷은 다른 우두머리 방어구와 값이 다르다', () async {
      final blunt = await repository.countOf(
        code: 11017,
        mainCategory: 15,
        name: '우둔한 나무 정령의 갑옷',
        enhancementLevel: 20,
      );
      final other = await repository.countOf(
        code: 11101,
        mainCategory: 15,
        name: '그리폰의 투구',
        enhancementLevel: 20,
      );

      expect(blunt, 24460);
      expect(other, 21744);
    });

    test('같은 이름이라도 mainCategory가 다르면 매칭되지 않는다', () async {
      // `쿠툼의 심장`(30/2)이 보조무기 그룹에 섞이면 안 된다.
      final count = await repository.countOf(
        code: 9793,
        mainCategory: 30,
        name: '쿠툼의 심장',
        enhancementLevel: 20,
      );

      expect(count, isNull);
    });
  });

  group('최저가 슬롯', () {
    TradeMarketTemplate slotTemplate() {
      return TradeMarketTemplate(
        id: 'slot',
        name: 'slot',
        type: TradeMarketTemplateType.recipeCompare,
        variants: [
          _variant('A', [
            TradeMarketTemplateItem(
              quantity: 2,
              slot: const TradeMarketItemSlot(
                label: 'weapon',
                candidates: [
                  TradeMarketSlotCandidate(mainCategory: 1, prefixes: ['검은별']),
                ],
              ),
            ),
          ]),
        ],
      );
    }

    FakeTradeMarketService slotService({int cheapStock = 10}) {
      final service = FakeTradeMarketService(
        templates: {'slot': slotTemplate()},
        prices: {
          '11_0': _price(11, 500),
          '12_0': _price(12, 300, stock: cheapStock),
          '13_0': _price(13, 400),
        },
      );
      service.slotResolutions['weapon'] = [
        TradeMarketTemplateItem(code: 11),
        TradeMarketTemplateItem(code: 12),
        TradeMarketTemplateItem(code: 13),
      ];
      return service;
    }

    test('후보 중 최저 총원가를 고른다', () async {
      final controller = await _load(slotService(), 'slot');
      final item = controller.variants.first.items.first;

      expect(item.slotResolution?.code, 12);
      // 수량 2가 곱해진다.
      expect(item.totalCost, 600);
    });

    test('후보 전체를 들고 있어 왜 골랐는지 보여줄 수 있다', () async {
      final service = slotService();
      final controller = await _load(service, 'slot');
      final item = controller.variants.first.items.first;

      expect(controller.slotCandidates[item]?.length, 3);
      // 후보도 같은 배치 조회에 포함된다.
      expect(service.priceCallCount, 1);
      expect(service.lastRequestedKeys.toSet(), {'11_0', '12_0', '13_0'});
    });

    test('재고가 없는 후보는 더 싸도 뽑지 않는다', () async {
      final controller = await _load(slotService(cheapStock: 0), 'slot');
      final item = controller.variants.first.items.first;

      expect(item.slotResolution?.code, 13);
    });

    test('구성 요소가 있는 후보는 합계로 비교한다', () async {
      final service = FakeTradeMarketService(
        templates: {'slot': slotTemplate()},
        prices: {
          '11_0': _price(11, 500),
          '21_0': _price(21, 100),
          '22_0': _price(22, 2),
        },
      );
      // 장비 100 + 카프라스 2 × 300 = 700 > 단품 500
      service.slotResolutions['weapon'] = [
        TradeMarketTemplateItem(code: 11),
        TradeMarketTemplateItem(
          source: TradeMarketItemSource.derived,
          customName: '카프라스 돌파 장비',
          components: [
            TradeMarketTemplateItem(code: 21),
            TradeMarketTemplateItem(code: 22, quantity: 300),
          ],
        ),
      ];

      final controller = await _load(service, 'slot');
      final item = controller.variants.first.items.first;

      expect(item.slotResolution?.code, 11);
      expect(item.totalCost, 1000);
    });
  });
}
