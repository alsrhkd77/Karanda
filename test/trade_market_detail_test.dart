import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/bdo_item_info.dart';
import 'package:karanda/model/trade_market_price_data.dart';
import 'package:karanda/ui/trade_market/controllers/trade_market_detail_controller.dart';

import 'support/fake_bdo_item_info_service.dart';
import 'support/fake_trade_market_service.dart';

/// 상세 응답을 흉내 내는 가짜. 강화 단계별로 일별 가격을 만들어 준다.
class _DetailFakeService extends FakeTradeMarketService {
  final Map<String, List<TradeMarketPriceData>> detail;

  _DetailFakeService(this.detail);

  @override
  Future<Map<String, List<TradeMarketPriceData>>> getPriceDetailData(
    String code,
    BDORegion region,
  ) async =>
      detail;
}

/// [days]일치 가격을 만든다. 오래된 것이 앞(컨트롤러가 정렬·역순 처리한다).
List<TradeMarketPriceData> _history(
  int code,
  int level,
  int days, {
  int basePrice = 100,
  int buyOrders = 0,
}) {
  return List.generate(days, (index) {
    return TradeMarketPriceData(
      itemCode: code,
      enhancementLevel: level,
      price: basePrice + index,
      cumulativeVolume: 0,
      currentStock: 10,
      buyOrders: index == days - 1 ? buyOrders : 0,
      date: DateTime(2026, 1, 1).add(Duration(days: index)),
    );
  });
}

Future<TradeMarketDetailController> _open(
  Map<String, List<TradeMarketPriceData>> detail, {
  String code = "1",
}) async {
  final controller = TradeMarketDetailController(
    marketService: _DetailFakeService(detail),
    itemInfoService: FakeBDOItemInfoService([
      fakeItem(code: "1", name: "테스트 아이템", maxEnhancement: 20),
    ]),
    code: code,
    region: BDORegion.KR,
  );
  for (var i = 0; i < 4; i++) {
    await Future.delayed(Duration.zero);
  }
  return controller;
}

void main() {
  group('가격 이력 정렬', () {
    test('최신이 first가 되도록 뒤집는다', () async {
      final controller = await _open({'0': _history(1, 0, 10)});

      // 마지막 날 가격이 가장 비싸게 생성되므로 최신이 맨 앞이면 최대가다.
      expect(controller.latest.price, 109);
      expect(controller.prices.first.date.isAfter(controller.prices.last.date),
          isTrue);
    });
  });

  group('기간 선택', () {
    test('기본 기간은 90일이다', () async {
      final controller = await _open({'0': _history(1, 0, 90)});

      expect(controller.period, 90);
      expect(controller.pricesInPeriod.length, 90);
    });

    test('기간을 줄이면 최근 구간만 남는다', () async {
      final controller = await _open({'0': _history(1, 0, 90)});

      controller.selectPeriod(7);

      expect(controller.pricesInPeriod.length, 7);
      // 최신이 first이므로 앞에서 자른 구간이 최근이다.
      expect(controller.pricesInPeriod.first, controller.latest);
    });

    test('보유 데이터가 기간보다 짧으면 있는 만큼만 쓴다', () async {
      final controller = await _open({'0': _history(1, 0, 5)});

      expect(controller.pricesInPeriod.length, 5);
    });

    test('축 계산은 화면에 그리는 구간만 본다', () async {
      // 90일 중 최근 7일은 183~189, 전체는 100~189.
      final controller = await _open({'0': _history(1, 0, 90)});

      expect(controller.maxPrice, 189);
      expect(controller.minPrice, 100);

      controller.selectPeriod(7);

      expect(controller.maxPrice, 189);
      expect(controller.minPrice, 183);
    });
  });

  group('강화 단계 선택', () {
    test('0단계가 없으면 첫 단계를 고른다', () async {
      final controller = await _open({
        '1': _history(1, 1, 10),
        '2': _history(1, 2, 10),
      });

      // 하드코딩된 0이 아니라 실제 데이터의 첫 단계를 따른다.
      expect(controller.selected, 1);
      expect(controller.prices.isNotEmpty, isTrue);
    });

    test('0단계가 있으면 그대로 0을 쓴다', () async {
      final controller = await _open({
        '0': _history(1, 0, 10),
        '1': _history(1, 1, 10),
      });

      expect(controller.selected, 0);
    });

    test('없는 단계는 선택되지 않는다', () async {
      final controller = await _open({'0': _history(1, 0, 10)});

      controller.selectItem(5);

      expect(controller.selected, 0);
    });
  });

  group('구매 대기 수량', () {
    test('최신 레코드의 구매 대기 수량을 노출한다', () async {
      final controller =
          await _open({'0': _history(1, 0, 10, buyOrders: 1234)});

      expect(controller.latest.buyOrders, 1234);
    });
  });

  group('아이템 정보 조회 실패', () {
    test('카탈로그에 없는 코드면 빈 데이터로 끝낸다', () async {
      final controller = await _open({'0': _history(1, 0, 10)}, code: "999");

      expect(controller.data, isEmpty);
      expect(controller.enhancementLevels, isEmpty);
    });
  });

  group('호가창', () {
    test('상세 응답의 호가창을 파싱한다', () {
      final data = TradeMarketPriceData.listFromDetailJson({
        "item_num": 1,
        "enhancement_level": 0,
        "price_history": [100, 99, 98],
        "cumulative_volume": 10,
        "current_stock": 5,
        "buy_orders": 7,
        "order_book": [
          {"price": 110, "sell_orders": 3, "buy_orders": 0},
          {"price": 100, "sell_orders": 0, "buy_orders": 7},
        ],
        "updated_at": "2026-08-17T00:00:00Z",
      });

      // 재고·거래량과 마찬가지로 호가창도 최신 레코드에만 실린다.
      expect(data.first.orderBook.length, 2);
      expect(data.first.orderBook.first.price, 110);
      expect(data.first.orderBook.first.sellOrders, 3);
      expect(data.first.orderBook.last.buyOrders, 7);
      expect(data[1].orderBook, isEmpty);
    });

    test('호가창이 없는 구버전 응답도 그대로 읽힌다', () {
      final data = TradeMarketPriceData.listFromDetailJson({
        "item_num": 1,
        "enhancement_level": 0,
        "price_history": [100],
        "updated_at": "2026-08-17T00:00:00Z",
      });

      expect(data.first.orderBook, isEmpty);
      expect(data.first.price, 100);
    });
  });
}
