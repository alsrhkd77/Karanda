import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/ui/trade_market/templates/controllers/trade_market_template_editor_controller.dart';

import 'support/fake_bdo_item_info_service.dart';
import 'support/fake_trade_market_service.dart';

final _catalog = [
  fakeItem(code: "1", name: "거래 가능 아이템", maxEnhancement: 20),
  fakeItem(code: "2", name: "다른 아이템"),
  fakeItem(code: "3", name: "거래 불가 아이템", tradeAble: false),
];

Future<TradeMarketTemplateEditorController> _open(
  FakeTradeMarketService service, {
  String? templateId,
}) async {
  final controller = TradeMarketTemplateEditorController(
    tradeMarketService: service,
    itemInfoService: FakeBDOItemInfoService(_catalog),
    templateId: templateId,
  );
  await Future.delayed(Duration.zero);
  await Future.delayed(Duration.zero);
  return controller;
}

void main() {
  group('타입별 입력 항목 전환', () {
    test('단가 비교형은 산출량을 쓰고 역할·수수료를 숨긴다', () async {
      final controller = await _open(FakeTradeMarketService());
      controller.updateType(TradeMarketTemplateType.unitPrice);

      expect(controller.usesYield, isTrue);
      expect(controller.usesQuantity, isFalse);
      expect(controller.usesRole, isFalse);
      expect(controller.usesTaxAndLifeskill, isFalse);
    });

    test('준비물 총액형은 수량만 쓴다', () async {
      final controller = await _open(FakeTradeMarketService());
      controller.updateType(TradeMarketTemplateType.shoppingList);

      expect(controller.usesQuantity, isTrue);
      expect(controller.usesRole, isFalse);
      expect(controller.usesTaxAndLifeskill, isFalse);
    });

    test('차익형만 역할·수수료·생활 종류를 노출한다', () async {
      final controller = await _open(FakeTradeMarketService());
      controller.updateType(TradeMarketTemplateType.profit);

      expect(controller.usesQuantity, isTrue);
      expect(controller.usesRole, isTrue);
      expect(controller.usesTaxAndLifeskill, isTrue);
    });
  });

  group('아이템 추가', () {
    test('검색 대상에 거래 불가 아이템도 포함된다', () async {
      final controller = await _open(FakeTradeMarketService());

      final result = controller.searchItems("아이템", const Locale('ko', 'KR'));

      expect(result.length, 3);
    });

    test('거래 불가 아이템을 고르면 가격 직접 입력 항목으로 들어간다', () async {
      final controller = await _open(FakeTradeMarketService());

      controller.addItem(_catalog[2]);

      expect(controller.items.single.source, TradeMarketItemSource.offMarket);
      expect(controller.items.single.isOffMarket, isTrue);
    });

    test('거래 가능 아이템은 거래소 조회 대상으로 들어간다', () async {
      final controller = await _open(FakeTradeMarketService());

      controller.addItem(_catalog[0]);

      expect(controller.items.single.source, TradeMarketItemSource.market);
    });

    test('카탈로그에 없는 아이템을 이름·가격으로 직접 추가한다', () async {
      final controller = await _open(FakeTradeMarketService());

      final added = controller.addCustomItem("태초의 불꽃", 4000);

      expect(added, isTrue);
      expect(controller.items.single.code, isNull);
      expect(controller.items.single.customName, "태초의 불꽃");
      expect(controller.items.single.price, 4000);
    });

    test('같은 코드·강화 단계는 중복 추가되지 않는다', () async {
      final controller = await _open(FakeTradeMarketService());

      expect(controller.addItem(_catalog[0]), isTrue);
      expect(controller.addItem(_catalog[0]), isFalse);
      expect(controller.items.length, 1);
    });

    test('같은 이름의 직접 입력 아이템도 중복 추가되지 않는다', () async {
      final controller = await _open(FakeTradeMarketService());

      expect(controller.addCustomItem("태초의 불꽃", 1), isTrue);
      expect(controller.addCustomItem("태초의 불꽃", 2), isFalse);
      expect(controller.items.length, 1);
    });

    test('이름이 비면 직접 추가가 거부된다', () async {
      final controller = await _open(FakeTradeMarketService());

      expect(controller.addCustomItem("   ", 100), isFalse);
      expect(controller.items, isEmpty);
    });
  });

  group('저장', () {
    test('타입·수수료·생활 종류를 함께 저장한다', () async {
      final service = FakeTradeMarketService();
      final controller = await _open(service);

      controller.nameController.text = "내 템플릿";
      controller.updateType(TradeMarketTemplateType.profit);
      controller.updateLifeskill(TradeMarketLifeskill.cooking);
      controller.updateTaxEnabled(true);
      controller.updateValuePackage(true);
      controller.familyFameController.text = "1200";
      controller.addItem(_catalog[0]);

      expect(await controller.save(), isTrue);

      final saved = service.saved.single;
      expect(saved.type, TradeMarketTemplateType.profit);
      expect(saved.lifeskill, TradeMarketLifeskill.cooking);
      expect(saved.tax.enabled, isTrue);
      expect(saved.tax.valuePackage, isTrue);
      expect(saved.tax.familyFame, 1200);
    });

    test('직접 입력 아이템은 가격까지 저장된다', () async {
      final service = FakeTradeMarketService();
      final controller = await _open(service);

      controller.nameController.text = "제작법";
      controller.addCustomItem("황혼의 보석", 12345);

      await controller.save();

      final item = service.saved.single.items.single;
      expect(item.source, TradeMarketItemSource.offMarket);
      expect(item.offMarketPrice, 12345);
      expect(item.code, isNull);
    });

    test('이름이나 아이템이 비면 저장하지 않는다', () async {
      final service = FakeTradeMarketService();
      final controller = await _open(service);

      expect(controller.canSave, isFalse);
      expect(await controller.save(), isFalse);

      controller.nameController.text = "이름만";
      expect(controller.canSave, isFalse);
    });
  });

  group('편집 모드', () {
    test('저장된 타입·수수료·아이템 구성을 그대로 불러온다', () async {
      final service = FakeTradeMarketService(templates: {
        'edit': TradeMarketTemplate(
          id: 'edit',
          name: '기존 템플릿',
          type: TradeMarketTemplateType.unitPrice,
          lifeskill: TradeMarketLifeskill.processing,
          tax: const TradeMarketTaxOption(enabled: true, merchantRing: true),
          items: [
            TradeMarketTemplateItem(code: 1, yieldAmount: 25),
            TradeMarketTemplateItem(
              source: TradeMarketItemSource.offMarket,
              customName: '태초의 불꽃',
              offMarketPrice: 500,
            ),
          ],
        ),
      });

      final controller = await _open(service, templateId: 'edit');

      expect(controller.type, TradeMarketTemplateType.unitPrice);
      expect(controller.lifeskill, TradeMarketLifeskill.processing);
      expect(controller.taxEnabled, isTrue);
      expect(controller.merchantRing, isTrue);
      expect(controller.items.length, 2);
      expect(controller.items[0].yieldAmount, 25);
      expect(controller.items[1].price, 500);
    });

    test('타입을 바꿔도 수량과 산출량이 서로 지워지지 않는다', () async {
      final service = FakeTradeMarketService(templates: {
        'edit': TradeMarketTemplate(
          id: 'edit',
          name: '기존 템플릿',
          type: TradeMarketTemplateType.unitPrice,
          items: [TradeMarketTemplateItem(code: 1, quantity: 7, yieldAmount: 25)],
        ),
      });

      final controller = await _open(service, templateId: 'edit');
      controller.updateType(TradeMarketTemplateType.shoppingList);
      await controller.save();

      final item = service.saved.single.items.single;
      expect(item.quantity, 7);
      expect(item.yieldAmount, 25);
    });
  });
}
