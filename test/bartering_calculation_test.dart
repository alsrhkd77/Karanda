import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/model/bartering/bartering.dart';
import 'package:karanda/model/bartering/bartering_mastery.dart';
import 'package:karanda/model/bartering/bartering_settings.dart';
import 'package:karanda/model/bartering/ship_profile.dart';
import 'package:karanda/repository/bartering_repository.dart';
import 'package:karanda/ui/bartering/controller/bartering_parley_controller.dart';
import 'package:karanda/ui/bartering/controller/bartering_weight_controller.dart';

import 'support/fake_bartering_data_source.dart';

/// 물물교환(교역) 계산 로직 회귀 방지 테스트.
///
/// 검증 대상 계약은 `docs/features/bartering.md`에 정의된 게임 사양이다.
/// - `reducedParley = floor(requiredParley * (1 - reductionRate))`
/// - `reductionRate = 숙련도 + (밸류팩 ? 0.1 : 0) + (클레이아 ? 0.1 : 0)`
/// - 교역 증서 1장 = 250,000 파레이
///
/// 기대값은 구현식을 다시 쓰지 않고 **직접 계산한 정수 리터럴**로 적는다.
/// 그래야 구현이 바뀌었을 때 테스트가 함께 따라가지 않고 실패한다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// 설정 스트림(BehaviorSubject)과 숙련도 로딩이 전달될 때까지 이벤트 큐를 비운다.
  Future<void> settle() => pumpEventQueue();

  BarteringSettings buildSettings({
    bool valuePack = false,
    bool useCleia = false,
    double reductionRate = 0.1723,
  }) {
    return BarteringSettings(
      valuePack: valuePack,
      mastery: BarteringMastery(reductionRate: reductionRate),
      shipProfiles: [ShipProfile(name: "test ship", useCleia: useCleia)],
    );
  }

  Future<BarteringParleyController> buildParleyController({
    BarteringSettings? settings,
    FakeBarteringDataSource? dataSource,
  }) async {
    final source =
        dataSource ?? FakeBarteringDataSource(settings: settings ?? buildSettings());
    final controller = BarteringParleyController(
      repository: BarteringRepository(barteringDataSource: source),
    );
    await settle();
    return controller;
  }

  group('Bartering.decreasesParley (파레이 감소율)', () {
    test('감소율 0이면 기준 소모량 그대로다', () {
      final item = Bartering(exchangePoint: "lv1_trades", requiredParley: 14286);
      item.decreasesParley(
        mastery: BarteringMastery(reductionRate: 0),
        useValuePack: false,
        useCleia: false,
      );
      expect(item.reducedParley, 14286);
    });

    test('숙련도만 적용된다 (master 1: 17.23%)', () {
      // 14286 * 0.8277 = 11824.5222 → floor
      final item = Bartering(exchangePoint: "lv1_trades", requiredParley: 14286);
      item.decreasesParley(
        mastery: BarteringMastery(reductionRate: 0.1723),
        useValuePack: false,
        useCleia: false,
      );
      expect(item.reducedParley, 11824);
    });

    test('밸류팩이 10%p를 더한다', () {
      // 14286 * 0.7277 = 10395.9222 → floor
      final item = Bartering(exchangePoint: "lv1_trades", requiredParley: 14286);
      item.decreasesParley(
        mastery: BarteringMastery(reductionRate: 0.1723),
        useValuePack: true,
        useCleia: false,
      );
      expect(item.reducedParley, 10395);
    });

    test('클레이아가 10%p를 더한다', () {
      final item = Bartering(exchangePoint: "lv1_trades", requiredParley: 14286);
      item.decreasesParley(
        mastery: BarteringMastery(reductionRate: 0.1723),
        useValuePack: false,
        useCleia: true,
      );
      expect(item.reducedParley, 10395);
    });

    test('밸류팩과 클레이아는 함께 20%p 가산된다', () {
      // 14286 * 0.6277 = 8967.3222 → floor
      final item = Bartering(exchangePoint: "lv1_trades", requiredParley: 14286);
      item.decreasesParley(
        mastery: BarteringMastery(reductionRate: 0.1723),
        useValuePack: true,
        useCleia: true,
      );
      expect(item.reducedParley, 8967);
    });

    test('까마귀 주화 교역(21650)도 같은 식을 따른다', () {
      // 21650 * 0.8277 = 17919.705 → floor
      final item = Bartering(exchangePoint: "coin_trades", requiredParley: 21650);
      item.decreasesParley(
        mastery: BarteringMastery(reductionRate: 0.1723),
        useValuePack: false,
        useCleia: false,
      );
      expect(item.reducedParley, 17919);
    });

    test('결과가 정수로 딱 떨어지면 floor가 값을 깎지 않는다', () {
      // 14286 * 0.5 = 7143.0
      final item = Bartering(exchangePoint: "lv1_trades", requiredParley: 14286);
      item.decreasesParley(
        mastery: BarteringMastery(reductionRate: 0.5),
        useValuePack: false,
        useCleia: false,
      );
      expect(item.reducedParley, 7143);
    });

    test('소수점 이하는 항상 버린다 (반올림이 아니다)', () {
      // 14286 * 0.75 = 10714.5 → 10715가 아니라 10714
      final item = Bartering(exchangePoint: "lv1_trades", requiredParley: 14286);
      item.decreasesParley(
        mastery: BarteringMastery(reductionRate: 0.25),
        useValuePack: false,
        useCleia: false,
      );
      expect(item.reducedParley, 10714);
    });

    test('재계산은 항상 requiredParley 기준이라 반복 적용해도 누적되지 않는다', () {
      final item = Bartering(exchangePoint: "lv1_trades", requiredParley: 14286);
      final mastery = BarteringMastery(reductionRate: 0.1723);
      item.decreasesParley(
        mastery: mastery,
        useValuePack: true,
        useCleia: true,
      );
      item.decreasesParley(
        mastery: mastery,
        useValuePack: false,
        useCleia: false,
      );
      expect(item.reducedParley, 11824);
    });
  });

  group('Bartering.totalParley', () {
    test('감소 적용 소모량 * 수량이다', () {
      final item = Bartering(exchangePoint: "lv1_trades", requiredParley: 14286);
      item.decreasesParley(
        mastery: BarteringMastery(reductionRate: 0.1723),
        useValuePack: false,
        useCleia: false,
      );
      item.count = 7;
      // 11824 * 7
      expect(item.totalParley, 82768);
    });

    test('수량이 0이면 0이다', () {
      final item = Bartering(exchangePoint: "lv1_trades", requiredParley: 14286);
      expect(item.totalParley, 0);
    });
  });

  group('BarteringParleyController', () {
    test('설정 스트림이 도착하면 모든 교환처의 감소 파레이가 반영된다', () async {
      final controller = await buildParleyController(
        settings: buildSettings(valuePack: true, useCleia: true),
      );
      addTearDown(controller.dispose);

      expect(controller.settings, isNotNull);
      expect(controller.parleyReductionRate, closeTo(0.3723, 1e-9));
      // lv1~lv7 + 일반 교역(14286) → 8967, 까마귀 주화(21650) → 13589
      // 21650 * 0.6277 = 13589.705
      expect(
        controller.locations
            .where((e) => e.requiredParley == 14286)
            .every((e) => e.reducedParley == 8967),
        isTrue,
      );
      expect(
        controller.locations
            .firstWhere((e) => e.exchangePoint == "coin_trades")
            .reducedParley,
        13589,
      );
    });

    test('설정이 바뀌면 감소 파레이를 다시 계산한다', () async {
      final dataSource = FakeBarteringDataSource(settings: buildSettings());
      final repository = BarteringRepository(barteringDataSource: dataSource);
      final controller = BarteringParleyController(repository: repository);
      await settle();
      addTearDown(controller.dispose);

      expect(controller.locations.first.reducedParley, 11824);

      await repository.saveSettings(buildSettings(valuePack: true));
      await settle();

      expect(controller.locations.first.reducedParley, 10395);
      expect(controller.parleyReductionRate, closeTo(0.2723, 1e-9));
    });

    test('totalParley는 모든 교환처 소모량의 합이다', () async {
      final controller = await buildParleyController();
      addTearDown(controller.dispose);

      controller.updateCount(index: 0, value: 3);
      controller.updateCount(index: 7, value: 2);

      // lv1_trades 11824 * 3 + coin_trades(21650 * 0.8277 = 17919) * 2
      expect(controller.locations[7].exchangePoint, "coin_trades");
      expect(controller.totalParley, 11824 * 3 + 17919 * 2);
    });

    test('수량 증감은 0~999로 제한된다', () async {
      final controller = await buildParleyController();
      addTearDown(controller.dispose);

      controller.decreaseCount(0);
      expect(controller.locations[0].count, 0);

      controller.updateCount(index: 0, value: 999);
      controller.increaseCount(0);
      expect(controller.locations[0].count, 999);

      controller.decreaseCount(0);
      expect(controller.locations[0].count, 998);
    });

    test('applyCount는 해당 행 소모를 consumed에 누적하고 수량을 비운다', () async {
      final controller = await buildParleyController();
      addTearDown(controller.dispose);

      controller.updateCount(index: 0, value: 4);
      controller.applyCount(0);

      expect(controller.consumed, 11824 * 4);
      expect(controller.locations[0].count, 0);
      expect(controller.totalParley, 0);

      controller.updateCount(index: 0, value: 1);
      controller.applyCount(0);
      expect(controller.consumed, 11824 * 5);
    });

    test('수량이 0인 교환처는 applyCount로 확정되지 않는다', () async {
      final controller = await buildParleyController();
      addTearDown(controller.dispose);

      controller.applyCount(0);

      expect(controller.consumed, 0);
      expect(controller.canUndoApply, isFalse);
    });

    test('undoLastApply는 직전 확정을 소모량과 수량 모두 되돌린다', () async {
      final controller = await buildParleyController();
      addTearDown(controller.dispose);

      expect(controller.canUndoApply, isFalse);

      controller.updateCount(index: 0, value: 4);
      controller.applyCount(0);
      expect(controller.canUndoApply, isTrue);

      controller.undoLastApply();

      expect(controller.consumed, 0);
      expect(controller.locations[0].count, 4);
      expect(controller.canUndoApply, isFalse);
    });

    test('되돌리기는 확정한 역순으로 하나씩 적용된다', () async {
      final controller = await buildParleyController();
      addTearDown(controller.dispose);

      controller.updateCount(index: 0, value: 2);
      controller.applyCount(0);
      controller.updateCount(index: 1, value: 3);
      controller.applyCount(1);

      expect(controller.consumed, 11824 * 2 + 11824 * 3);

      controller.undoLastApply();
      expect(controller.consumed, 11824 * 2);
      expect(controller.locations[1].count, 3);
      expect(controller.locations[0].count, 0);

      controller.undoLastApply();
      expect(controller.consumed, 0);
      expect(controller.locations[0].count, 2);
    });

    test('되돌릴 것이 없으면 아무 일도 하지 않는다', () async {
      final controller = await buildParleyController();
      addTearDown(controller.dispose);

      controller.undoLastApply();

      expect(controller.consumed, 0);
      expect(controller.locations.every((e) => e.count == 0), isTrue);
    });

    test('확정 후 설정이 바뀌어도 되돌릴 때는 확정 당시 소모량을 되돌린다', () async {
      final dataSource = FakeBarteringDataSource(settings: buildSettings());
      final repository = BarteringRepository(barteringDataSource: dataSource);
      final controller = BarteringParleyController(repository: repository);
      await settle();
      addTearDown(controller.dispose);

      controller.updateCount(index: 0, value: 2);
      controller.applyCount(0);
      expect(controller.consumed, 11824 * 2);

      // 밸류팩을 켜면 감소 파레이가 11824 → 10395로 바뀐다.
      await repository.saveSettings(buildSettings(valuePack: true));
      await settle();
      expect(controller.locations[0].reducedParley, 10395);

      controller.undoLastApply();

      expect(controller.consumed, 0);
    });

    test('resetAll은 되돌리기 이력도 비운다', () async {
      final controller = await buildParleyController();
      addTearDown(controller.dispose);

      controller.updateCount(index: 0, value: 2);
      controller.applyCount(0);

      controller.resetAll();

      expect(controller.canUndoApply, isFalse);
    });

    test('교역 증서는 1장당 250,000 파레이이며 0~99장으로 제한된다', () async {
      final controller = await buildParleyController();
      addTearDown(controller.dispose);

      expect(controller.parley, 1000000);
      expect(controller.tradeVoucher, 0);

      controller.decreaseTradeVoucher();
      expect(controller.tradeVoucher, 0);
      expect(controller.parley, 1000000);

      controller.increaseTradeVoucher();
      controller.increaseTradeVoucher();
      expect(controller.tradeVoucher, 2);
      expect(controller.parley, 1500000);

      controller.decreaseTradeVoucher();
      expect(controller.tradeVoucher, 1);
      expect(controller.parley, 1250000);
    });

    test('교역 증서 상한 99장을 넘기지 않는다', () async {
      final controller = await buildParleyController();
      addTearDown(controller.dispose);

      for (int i = 0; i < 120; i++) {
        controller.increaseTradeVoucher();
      }
      expect(controller.tradeVoucher, 99);
      expect(controller.parley, 1000000 + 250000 * 99);
    });

    test('보유 파레이는 0 아래로 내려가지 않는다', () async {
      final controller = await buildParleyController();
      addTearDown(controller.dispose);

      controller.onParleyTextUpdate("100000");
      controller.increaseTradeVoucher();
      controller.decreaseTradeVoucher();

      expect(controller.parley, 100000);

      controller.onParleyTextUpdate("0");
      controller.increaseTradeVoucher();
      expect(controller.parley, 250000);
    });

    test('파레이 입력이 숫자가 아니면 0으로 처리한다', () async {
      final controller = await buildParleyController();
      addTearDown(controller.dispose);

      controller.onParleyTextUpdate("abc");
      expect(controller.parley, 0);

      controller.onParleyTextUpdate(null);
      expect(controller.parley, 0);
    });

    test('resetAll은 세션 상태를 초기값으로 되돌린다', () async {
      final controller = await buildParleyController();
      addTearDown(controller.dispose);

      controller.start();
      controller.increaseTradeVoucher();
      controller.updateCount(index: 0, value: 5);
      controller.applyCount(0);
      controller.updateCount(index: 1, value: 3);

      controller.resetAll();

      expect(controller.started, isFalse);
      expect(controller.parley, 1000000);
      expect(controller.consumed, 0);
      expect(controller.tradeVoucher, 0);
      expect(controller.totalParley, 0);
      expect(controller.locations.every((e) => e.count == 0), isTrue);
    });

    test('배 프로필을 선택하면 인덱스를 저장한다', () async {
      final dataSource = FakeBarteringDataSource(
        settings: BarteringSettings(
          shipProfiles: [
            ShipProfile(name: "first"),
            ShipProfile(name: "second", useCleia: true),
          ],
        ),
      );
      final controller = await buildParleyController(dataSource: dataSource);
      addTearDown(controller.dispose);

      controller.onProfileSelect(ShipProfile(name: "second"));
      await settle();

      expect(dataSource.saveCount, 1);
      expect(dataSource.settings.lastSelectedShipIndex, 1);
      // 두 번째 배는 클레이아 사용 → 감소율 27.23%
      expect(controller.parleyReductionRate, closeTo(0.2723, 1e-9));
      expect(controller.locations.first.reducedParley, 10395);
    });

    test('목록에 없는 배를 선택해도 인덱스가 음수가 되지 않는다', () async {
      final dataSource = FakeBarteringDataSource(settings: buildSettings());
      final controller = await buildParleyController(dataSource: dataSource);
      addTearDown(controller.dispose);

      controller.onProfileSelect(ShipProfile(name: "unknown"));
      await settle();

      expect(dataSource.settings.lastSelectedShipIndex, 0);
    });
  });

  group('BarteringWeightController', () {
    Future<BarteringWeightController> build() async {
      final controller = BarteringWeightController(
        repository: BarteringRepository(
          barteringDataSource: FakeBarteringDataSource(settings: buildSettings()),
        ),
      );
      await settle();
      return controller;
    }

    test('교역품 단계별 산출 무게가 게임 사양과 일치한다', () async {
      final controller = await build();
      addTearDown(controller.dispose);

      expect(
        controller.tradeGoods.map((e) => e.outputWeight).toList(),
        [100, 400, 900, 1000, 1000, 2000, 2000, 0],
      );
      expect(controller.tradeGoods.last.exchangePoint, "etc");
      expect(controller.tradeGoods.last.count, 1);
    });

    test('totalWeight는 산출 무게 * 수량의 합이다', () async {
      final controller = await build();
      addTearDown(controller.dispose);

      controller.updateCount(index: 0, value: 3); // 100 * 3
      controller.updateCount(index: 2, value: 2); // 900 * 2
      controller.updateCount(index: 6, value: 1); // 2000 * 1

      expect(controller.totalWeight, 300 + 1800 + 2000);
    });

    test('기타 항목은 무게를 직접 입력한다', () async {
      final controller = await build();
      addTearDown(controller.dispose);

      controller.updateEtcWeight(153.5);
      expect(controller.totalWeight, 153.5);

      controller.updateCount(index: 7, value: 4);
      expect(controller.totalWeight, 614.0);
    });

    test('수량 증감은 0~999로 제한된다', () async {
      final controller = await build();
      addTearDown(controller.dispose);

      controller.decreaseCount(0);
      expect(controller.tradeGoods[0].count, 0);

      controller.updateCount(index: 0, value: 999);
      controller.increaseCount(0);
      expect(controller.tradeGoods[0].count, 999);
    });

    test('resetAll은 기타 항목만 수량 1로 되돌린다', () async {
      final controller = await build();
      addTearDown(controller.dispose);

      controller.updateCount(index: 0, value: 5);
      controller.updateCount(index: 7, value: 9);
      controller.updateEtcWeight(500);

      controller.resetAll();

      expect(controller.tradeGoods.take(7).every((e) => e.count == 0), isTrue);
      expect(controller.tradeGoods.last.count, 1);
      expect(controller.tradeGoods.last.outputWeight, 0);
      expect(controller.totalWeight, 0);
    });
  });
}
