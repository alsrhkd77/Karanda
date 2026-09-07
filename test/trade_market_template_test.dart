import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/data_source/trade_market_data_source.dart';
import 'package:karanda/model/trade_market_price_data.dart';
import 'package:karanda/model/trade_market_template.dart';

TradeMarketPriceData _price(int code, int price, {int enhancementLevel = 0}) {
  return TradeMarketPriceData(
    itemCode: code,
    enhancementLevel: enhancementLevel,
    price: price,
    cumulativeVolume: 0,
    currentStock: 1,
    date: DateTime(2026, 8, 17),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('구 형식 템플릿 마이그레이션', () {
    // 타입 도입 이전 저장 형식. 수량이 `value` 하나에 담겨 있고 type/tax/lifeskill이 없다.
    final legacyJson = {
      "id": "legacy-id",
      "name": "구 템플릿",
      "items": [
        {"code": 1, "enhancement level": 0, "value": 3, "role": "material"},
        {"code": 2, "enhancement level": 2, "value": 1, "role": "result"},
      ],
    };

    test('type이 없으면 차익형으로 읽어 기존 동작을 유지한다', () {
      final template = TradeMarketTemplate.fromJson(legacyJson);

      expect(template.type, TradeMarketTemplateType.profit);
      expect(template.id, "legacy-id");
      expect(template.materials.length, 1);
      expect(template.results.length, 1);
    });

    test('value를 수량으로 읽는다', () {
      final template = TradeMarketTemplate.fromJson(legacyJson);

      expect(template.materials.first.quantity, 3);
      expect(template.results.first.enhancementLevel, 2);
    });

    test('수수료는 미적용, 생활은 none으로 읽어 수치가 달라지지 않게 한다', () {
      final template = TradeMarketTemplate.fromJson(legacyJson);

      expect(template.tax.enabled, isFalse);
      expect(template.lifeskill, TradeMarketLifeskill.none);
    });

    test('구 형식을 읽어 새 형식으로 저장해도 값이 보존된다', () {
      final template = TradeMarketTemplate.fromJson(legacyJson);
      final round = TradeMarketTemplate.fromJson(template.toJson());

      expect(round.id, "legacy-id");
      expect(round.name, "구 템플릿");
      expect(round.type, TradeMarketTemplateType.profit);
      expect(round.materials.first.quantity, 3);
      expect(round.results.first.enhancementLevel, 2);
    });
  });

  group('아이템 출처별 가격 계산', () {
    test('market 아이템은 조회된 최신가를 쓴다', () {
      final item = TradeMarketTemplateItem(code: 1, quantity: 3)
        ..marketPrice = _price(1, 100);

      expect(item.unitCost, 100);
      expect(item.totalCost, 300);
    });

    test('조회 전에는 null이라 합계에서 구분할 수 있다', () {
      final item = TradeMarketTemplateItem(code: 1, quantity: 3);

      expect(item.unitCost, isNull);
      expect(item.totalCost, isNull);
    });

    test('offMarket 아이템은 지정 가격을 쓰고 조회 대상에서 빠진다', () {
      final item = TradeMarketTemplateItem(
        source: TradeMarketItemSource.offMarket,
        customName: "태초의 불꽃",
        quantity: 2,
        offMarketPrice: 500,
      );

      expect(item.unitCost, 500);
      expect(item.totalCost, 1000);
      expect(item.needsMarketPrice, isFalse);
      expect(item.key, isNull);
    });

    test('derived 아이템은 구성 요소 합계를 가격으로 쓴다', () {
      // 황혼의 보석 = 마력의 파편 100 + 카프라스의 돌 20,000
      final shard = TradeMarketTemplateItem(code: 4918, quantity: 100)
        ..marketPrice = _price(4918, 10);
      final caphras = TradeMarketTemplateItem(code: 721003, quantity: 20000)
        ..marketPrice = _price(721003, 2);
      final gem = TradeMarketTemplateItem(
        source: TradeMarketItemSource.derived,
        customName: "황혼의 보석",
        quantity: 2,
        components: [shard, caphras],
      );

      expect(gem.unitCost, 100 * 10 + 20000 * 2);
      expect(gem.totalCost, (100 * 10 + 20000 * 2) * 2);
    });

    test('구성 요소 하나라도 조회 전이면 derived 가격도 null이다', () {
      final gem = TradeMarketTemplateItem(
        source: TradeMarketItemSource.derived,
        components: [
          TradeMarketTemplateItem(code: 4918, quantity: 100)
            ..marketPrice = _price(4918, 10),
          TradeMarketTemplateItem(code: 721003, quantity: 20000),
        ],
      );

      expect(gem.unitCost, isNull);
    });
  });

  group('조회 대상 수집', () {
    test('구성 요소와 제작법까지 훑어 한 번에 조회할 목록을 만든다', () {
      final template = TradeMarketTemplate(
        name: "군왕 보조무기",
        type: TradeMarketTemplateType.recipeCompare,
        items: [
          TradeMarketTemplateItem(
            source: TradeMarketItemSource.derived,
            components: [
              TradeMarketTemplateItem(code: 4918, quantity: 100),
              TradeMarketTemplateItem(code: 721003, quantity: 20000),
            ],
          ),
        ],
        variants: [
          TradeMarketRecipeVariant(
            name: "방법 1",
            items: [TradeMarketTemplateItem(code: 715001, quantity: 2)],
          ),
        ],
      );

      final codes = template.marketItems.map((item) => item.code).toList();

      expect(codes, containsAll([4918, 721003, 715001]));
      // derived 부모 자신은 조회 대상이 아니다.
      expect(template.marketItems.length, 3);
    });

    test('offMarket 아이템은 조회 목록에서 빠진다', () {
      final template = TradeMarketTemplate(
        name: "테스트",
        items: [
          TradeMarketTemplateItem(code: 1),
          TradeMarketTemplateItem(
            source: TradeMarketItemSource.offMarket,
            customName: "거래 불가",
            offMarketPrice: 10,
          ),
        ],
      );

      expect(template.marketItems.length, 1);
      expect(template.marketItems.first.code, 1);
    });
  });

  group('빌트인 복제', () {
    test('복제본은 새 id를 받고 편집 가능해진다', () {
      final builtIn = TradeMarketTemplate(
        id: "melody_of_stars",
        name: "melody_of_stars",
        type: TradeMarketTemplateType.unitPrice,
        items: [TradeMarketTemplateItem(code: 11609, yieldAmount: 5)],
        isBuiltIn: true,
      );

      final copied = builtIn.copyAsUserTemplate(name: "내 별의 선율");

      expect(copied.id, isNot("melody_of_stars"));
      expect(copied.isBuiltIn, isFalse);
      expect(copied.type, TradeMarketTemplateType.unitPrice);
      expect(copied.items.first.yieldAmount, 5);
    });

    test('복제본 아이템은 원본과 분리되어 런타임 가격을 공유하지 않는다', () {
      final builtIn = TradeMarketTemplate(
        name: "원본",
        items: [TradeMarketTemplateItem(code: 1)],
        isBuiltIn: true,
      );

      final copied = builtIn.copyAsUserTemplate(name: "사본");
      copied.items.first.marketPrice = _price(1, 100);

      expect(builtIn.items.first.marketPrice, isNull);
    });
  });

  group('빌트인 에셋', () {
    // 실제 에셋을 읽어 구조가 깨지지 않았는지 확인한다.
    final dataSource = TradeMarketDataSource();

    test('군왕 주무기는 제작법 3종을 갖는다', () async {
      final template = await dataSource.getBuiltInTemplate('sovereign_main_weapon');

      expect(template.type, TradeMarketTemplateType.recipeCompare);
      expect(template.isBuiltIn, isTrue);
      expect(template.variants.length, 3);
    });

    test('군왕 보조무기만 제작법이 4종이다', () async {
      final sub = await dataSource.getBuiltInTemplate('sovereign_sub_weapon');
      final awakening =
          await dataSource.getBuiltInTemplate('sovereign_awakening_weapon');

      expect(sub.variants.length, 4);
      expect(awakening.variants.length, 3);
    });

    test('방법 1은 검은별 무기 2개를 쓴다', () async {
      final template = await dataSource.getBuiltInTemplate('sovereign_main_weapon');
      final item = template.variants.first.items.single;

      expect(item.slot, isNotNull);
      expect(item.quantity, 2);
      expect(item.slot!.candidates.single.prefixes, ['검은별']);
      expect(item.slot!.candidates.single.enhancementLevel, 20);
    });

    test('방법 3의 우두머리 무기는 카프라스 20단계를 요구한다', () async {
      final template = await dataSource.getBuiltInTemplate('sovereign_main_weapon');
      final boss = template.variants[2].items[1];

      expect(boss.slot!.candidates.single.caphrasLevel, 20);
      expect(boss.slot!.candidates.single.prefixes, ['크자카', '오핀 테트의 빛']);
    });

    test('황혼의 보석은 마력의 파편 100 + 카프라스의 돌 20,000으로 계산된다', () async {
      final template = await dataSource.getBuiltInTemplate('sovereign_main_weapon');
      final gem = template.variants[2].items[2];

      expect(gem.source, TradeMarketItemSource.derived);
      expect(gem.components.length, 2);
      expect(gem.components[0].code, 4918);
      expect(gem.components[0].quantity, 100);
      expect(gem.components[1].code, 721003);
      expect(gem.components[1].quantity, 20000);
    });

    test('빌트인 슬롯은 조회 대상에서 자기 자신을 뺀다', () async {
      final template = await dataSource.getBuiltInTemplate('sovereign_main_weapon');

      // 슬롯 자체는 후보를 펼쳐야 조회할 수 있으므로 marketItems에 들어가지 않는다.
      expect(
        template.marketItems.every((item) => item.slot == null),
        isTrue,
      );
    });

    test('그믐달 향로는 가공식 3종을 갖는다', () async {
      final template =
          await dataSource.getBuiltInTemplate('crescent_incense_burner');

      expect(template.variants.length, 3);
      // 카탈로그에 없는 재료는 직접 입력 항목이다.
      expect(
        template.variants.first.items.any(
            (item) => item.source == TradeMarketItemSource.offMarket),
        isTrue,
      );
    });
  });
}
