import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_price_data.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/ui/trade_market/presets/controllers/trade_market_cooking_box_preset_controller.dart';

import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'support/fake_trade_market_service.dart';

/// 요리상자 재료는 코드가 많아 요청한 키를 그대로 가격으로 만들어 준다.
class _PricedFakeService extends FakeTradeMarketService {
  final Map<int, int> priceByCode;
  final Set<int> outOfStock;

  _PricedFakeService({this.priceByCode = const {}, this.outOfStock = const {}});

  @override
  Future<List<TradeMarketPriceData>> getPriceDataByKeys(
    List<String> keys,
    BDORegion region,
  ) async {
    priceCallCount += 1;
    lastRequestedKeys = keys;
    return keys.map((key) {
      final code = int.parse(key.split('_').first);
      return TradeMarketPriceData(
        itemCode: code,
        enhancementLevel: 0,
        price: priceByCode[code] ?? 1000,
        cumulativeVolume: 0,
        currentStock: outOfStock.contains(code) ? 0 : 100000,
        date: DateTime(2026, 8, 17),
      );
    }).toList();
  }
}

Future<TradeMarketCookingBoxPresetController> _open(
  FakeTradeMarketService service,
) async {
  final controller = TradeMarketCookingBoxPresetController(
    marketService: service,
    region: BDORegion.KR,
  );
  for (var i = 0; i < 6; i++) {
    await Future.delayed(Duration.zero);
  }
  return controller;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // 요리상자는 공헌도를 로컬에 저장하므로 인메모리 저장소를 붙여 준다.
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('요리상자 — 리뉴얼 전 동작 보존', () {
    test('상자 6종과 재료가 에셋 그대로 로드된다', () async {
      final controller = await _open(_PricedFakeService());

      expect(controller.boxKeys, ['9851', '9852', '9853', '9854', '9855', '9856']);
      // 기본 선택은 마지막 상자다.
      expect(controller.selectedBox, '9856');
      expect(controller.items, isNotNull);
      expect(controller.items!.isNotEmpty, isTrue);
    });

    test('납품 가능 횟수는 공헌도의 절반이다', () async {
      final controller = await _open(_PricedFakeService());

      controller.contributionsController.text = '400';

      expect(controller.deliveryCounts, 200);
    });

    test('재료는 재고 우선, 그다음 총비용 오름차순으로 정렬된다', () async {
      final controller = await _open(_PricedFakeService());
      final items = controller.items!;

      for (var i = 1; i < items.length; i++) {
        final prev = items[i - 1];
        final current = items[i];
        final prevStock = (prev.marketPrice?.currentStock ?? 0) > 0;
        final currentStock = (current.marketPrice?.currentStock ?? 0) > 0;
        if (prevStock == currentStock) {
          expect(
            prev.totalCost! <= current.totalCost!,
            isTrue,
            reason: '총비용이 오름차순이어야 한다',
          );
        } else {
          expect(prevStock, isTrue, reason: '재고 있는 재료가 앞에 와야 한다');
        }
      }
    });

    test('품절 재료는 더 싸도 뒤로 밀린다', () async {
      final controller = await _open(_PricedFakeService(
        priceByCode: const {9635: 1}, // 카마실비아 정식을 최저가로
        outOfStock: const {9635},
      ));
      final items = controller.items!;

      expect(items.last.code, 9635);
    });

    test('총비용은 단가 × 필요 수량이다', () async {
      final controller = await _open(_PricedFakeService(
        priceByCode: const {9635: 500},
      ));
      final target =
          controller.items!.firstWhere((item) => item.code == 9635);

      expect(target.unitCost, 500);
      expect(target.totalCost, 500 * target.quantity);
    });

    test('재료 전체를 배치 한 번으로 조회한다', () async {
      final service = _PricedFakeService();
      await _open(service);

      expect(service.priceCallCount, 1);
    });

    test('상자를 바꾸면 그 상자의 재료를 조회한다', () async {
      final service = _PricedFakeService();
      final controller = await _open(service);

      controller.selectBox('9851');
      for (var i = 0; i < 4; i++) {
        await Future.delayed(Duration.zero);
      }

      expect(controller.selectedBox, '9851');
      expect(service.priceCallCount, 2);
      expect(controller.isLoaded, isTrue);
    });

    test('이미 조회한 상자로 되돌아가면 다시 조회하지 않는다', () async {
      final service = _PricedFakeService();
      final controller = await _open(service);

      controller.selectBox('9851');
      for (var i = 0; i < 4; i++) {
        await Future.delayed(Duration.zero);
      }
      controller.selectBox('9856');
      for (var i = 0; i < 4; i++) {
        await Future.delayed(Duration.zero);
      }

      expect(service.priceCallCount, 2);
    });
  });

  group('숙련도 공용화', () {
    test('숙련도 구간별 은화 보너스가 리뉴얼 전 표와 같다', () async {
      // 리뉴얼 전 cooking_box.json의 mastery 표에서 가져온 값들.
      final service = _PricedFakeService();

      expect(
          await service.royalTradeSilverBonusOf(
              TradeMarketLifeskill.cooking, 0),
          closeTo(0.0, 1e-9));
      expect(
          await service.royalTradeSilverBonusOf(
              TradeMarketLifeskill.cooking, 1200),
          closeTo(0.9293, 1e-9));
      // 구간 사이 값은 아래 구간(1150)을 따른다.
      expect(
          await service.royalTradeSilverBonusOf(
              TradeMarketLifeskill.cooking, 1199),
          closeTo(0.8612, 1e-9));
      expect(
          await service.royalTradeSilverBonusOf(
              TradeMarketLifeskill.cooking, 3000),
          closeTo(1.8125, 1e-9));
    });

    test('요리 숙련도를 바꾸면 공용 값으로 저장된다', () async {
      final service = _PricedFakeService();
      final controller = await _open(service);

      controller.proficiencyController.text = '2000';

      expect(service.mastery[TradeMarketLifeskill.cooking], 2000);
    });
  });
}
