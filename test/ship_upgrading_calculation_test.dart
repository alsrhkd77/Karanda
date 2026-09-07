import 'package:flutter_test/flutter_test.dart';
import 'package:karanda/enums/ship_upgrading_data_type.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_child_data.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_data.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_settings.dart';
import 'package:karanda/repository/ship_upgrading_repository.dart';
import 'package:karanda/ui/ship_upgrading/controller/ship_upgrading_controller.dart';

import 'support/fake_ship_upgrading_data_source.dart';

/// 선박 증축(배 강화) 소요 재료·달성률 계산 회귀 방지 테스트.
///
/// 실제 에셋(`assets/data/ship_upgrading.json`)은 규모가 크고 게임 패치마다 바뀌므로,
/// 계산 규칙만 드러나는 최소 데이터셋으로 검증한다.
///
/// 데이터셋 구조
/// - 선박 100: 부품 200 / 201 / 202 로 구성
/// - 부품 200: 재료 5807 x4, 5814 x2
/// - 부품 201: 재료 5807 x6
/// - 부품 202: 재료 5827 x5
/// - 선박 101: 부품 202 하나만 사용(선박 변경 검증용)
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// 설정·재고 스트림이 전달될 때까지 이벤트 큐를 비운다.
  Future<void> settle() => pumpEventQueue();

  ShipUpgradingData item({
    required int code,
    required ShipUpgradingDataType type,
    List<ShipUpgradingQuantityData> materials = const [],
    List<int> parent = const [],
  }) {
    return ShipUpgradingData(
      code: code,
      type: type,
      coin: 0,
      materials: materials,
      parent: parent,
    );
  }

  ShipUpgradingQuantityData need(int code, int count) =>
      ShipUpgradingQuantityData(code: code, count: count);

  List<ShipUpgradingData> buildBaseData() {
    return [
      item(
        code: 100,
        type: ShipUpgradingDataType.ship,
        materials: [need(200, 1), need(201, 1), need(202, 1)],
      ),
      item(
        code: 101,
        type: ShipUpgradingDataType.ship,
        materials: [need(202, 1)],
      ),
      item(
        code: 200,
        type: ShipUpgradingDataType.figurehead,
        materials: [need(5807, 4), need(5814, 2)],
        parent: [100],
      ),
      item(
        code: 201,
        type: ShipUpgradingDataType.plating,
        materials: [need(5807, 6)],
        parent: [100],
      ),
      item(
        code: 202,
        type: ShipUpgradingDataType.cannon,
        materials: [need(5827, 5)],
        parent: [100, 101],
      ),
      item(code: 5807, type: ShipUpgradingDataType.material),
      item(code: 5814, type: ShipUpgradingDataType.material),
      item(code: 5827, type: ShipUpgradingDataType.material),
    ];
  }

  Future<(ShipUpgradingController, ShipUpgradingRepository,
          FakeShipUpgradingDataSource)>
      build({Map<int, int>? stock, int selected = 100}) async {
    final dataSource = FakeShipUpgradingDataSource(
      baseData: buildBaseData(),
      stock: stock,
      settings: ShipUpgradingSettings(selected: selected),
    );
    final repository = ShipUpgradingRepository(dataSource: dataSource);
    final controller = ShipUpgradingController(repository: repository);
    await settle();
    return (controller, repository, dataSource);
  }

  Map<int, int> needsOf(Map<int, ShipUpgradingQuantityData> value) {
    return value.map((key, data) => MapEntry(key, data.count));
  }

  group('calcNeeds (총 소요 재료)', () {
    test('선택한 선박의 모든 부품 재료를 코드별로 합산한다', () async {
      final (controller, _, _) = await build();
      addTearDown(controller.dispose);

      // 5807은 부품 200(4개) + 부품 201(6개)에 걸쳐 있으므로 누적된다.
      expect(needsOf(controller.needs), {5807: 10, 5814: 2, 5827: 5});
    });

    test('보유 재고와 무관하게 전체 소요량을 유지한다', () async {
      final (controller, _, _) = await build(stock: {200: 1, 5807: 999});
      addTearDown(controller.dispose);

      expect(needsOf(controller.needs), {5807: 10, 5814: 2, 5827: 5});
    });

    test('선박을 바꾸면 소요 재료를 다시 계산한다', () async {
      final (controller, _, _) = await build();
      addTearDown(controller.dispose);

      controller.selectShip(controller.ships[101]);
      await settle();

      expect(controller.selectedParts.map((e) => e.code).toList(), [202]);
      expect(needsOf(controller.needs), {5827: 5});
    });
  });

  group('calcRealNeeds (남은 소요 재료)', () {
    test('이미 보유한 부품의 재료는 제외한다', () async {
      final (controller, _, _) = await build(stock: {200: 1});
      addTearDown(controller.dispose);

      // 부품 200이 완성돼 5807 4개와 5814 2개가 빠진다.
      expect(needsOf(controller.realNeeds), {5807: 6, 5827: 5});
    });

    test('모든 부품을 보유하면 남은 소요가 없다', () async {
      final (controller, _, _) = await build(stock: {200: 1, 201: 1, 202: 1});
      addTearDown(controller.dispose);

      expect(controller.realNeeds, isEmpty);
    });

    test('부품을 하나도 보유하지 않으면 총 소요량과 같다', () async {
      final (controller, _, _) = await build();
      addTearDown(controller.dispose);

      expect(needsOf(controller.realNeeds), needsOf(controller.needs));
    });
  });

  group('calcCompletionRate (달성률)', () {
    test('남은 소요 재료별 충족 비율의 평균이다', () async {
      final (controller, _, _) = await build(
        stock: {200: 1, 5807: 3, 5827: 5},
      );
      addTearDown(controller.dispose);

      // realNeeds = {5807: 6, 5827: 5}
      // (3/6 + 5/5) / 2 = 0.75
      expect(controller.completionRate, closeTo(0.75, 1e-9));
    });

    test('필요량을 초과 보유해도 100%를 넘지 않는다', () async {
      final (controller, _, _) = await build(
        stock: {5807: 9999, 5814: 9999, 5827: 9999},
      );
      addTearDown(controller.dispose);

      expect(controller.completionRate, closeTo(1.0, 1e-9));
    });

    test('아무것도 보유하지 않으면 0이다', () async {
      final (controller, _, _) = await build();
      addTearDown(controller.dispose);

      expect(controller.completionRate, 0.0);
    });

    test('선택된 선박이 없으면 0을 반환한다', () async {
      final (controller, _, _) = await build(selected: 999);
      addTearDown(controller.dispose);

      expect(controller.ship, isNull);
      expect(controller.completionRate, 0.0);
    });
  });

  group('completedParts (완성 부품)', () {
    test('보유 수량이 1인 부품만 완성으로 본다', () async {
      final (controller, _, _) = await build(stock: {200: 1, 201: 0});
      addTearDown(controller.dispose);

      expect(controller.completedParts, [200]);
    });

    test('재료 코드는 완성 부품 목록에 포함되지 않는다', () async {
      final (controller, _, _) = await build(stock: {5807: 1});
      addTearDown(controller.dispose);

      expect(controller.completedParts, isEmpty);
    });
  });

  group('사용자 재고 증감', () {
    test('증가는 9999에서 멈춘다', () async {
      final (controller, _, source) = await build(stock: {5807: 9998});
      addTearDown(controller.dispose);

      await controller.increaseUserStock(5807);
      expect(controller.stock[5807], 9999);

      await controller.increaseUserStock(5807);
      expect(controller.stock[5807], 9999);
      expect(source.stock[5807], 9999);
    });

    test('감소는 0에서 멈춘다', () async {
      final (controller, _, _) = await build(stock: {5807: 1});
      addTearDown(controller.dispose);

      await controller.decreaseUserStock(5807);
      expect(controller.stock[5807], 0);

      await controller.decreaseUserStock(5807);
      expect(controller.stock[5807], 0);
    });

    test('데이터에 없는 코드는 무시한다', () async {
      final (controller, _, _) = await build();
      addTearDown(controller.dispose);

      await controller.increaseUserStock(99999);
      expect(controller.stock.containsKey(99999), isFalse);
    });
  });

  group('dailyQuest (일일 퀘스트 보상 반영)', () {
    test('설정된 수량만큼 재고를 더한다', () async {
      final (controller, _, _) = await build(stock: {5807: 1, 5814: 0});
      addTearDown(controller.dispose);

      await controller.dailyQuest();

      // 기본 설정: 5807 +2, 5814 +10, 5827 +20
      expect(controller.stock[5807], 3);
      expect(controller.stock[5814], 10);
      expect(controller.stock[5827], 20);
    });

    test('9999를 넘지 않는다', () async {
      final (controller, _, _) = await build(stock: {5807: 9998});
      addTearDown(controller.dispose);

      await controller.dailyQuest();

      expect(controller.stock[5807], 9999);
    });
  });

  group('현행 동작 기록 (변경 시 의도 확인 필요)', () {
    test('재고 변경만으로는 realNeeds가 다시 계산되지 않는다', () async {
      final (controller, _, _) = await build();
      addTearDown(controller.dispose);

      expect(needsOf(controller.realNeeds), {5807: 10, 5814: 2, 5827: 5});

      // 부품 200을 완성해도 realNeeds에서 그 재료가 빠지지 않는다.
      // `_onStockUpdate`는 최초 1회(stock이 비어 있을 때)만 재계산하기 때문.
      await controller.updateUserStock(200, 1);
      await settle();

      expect(controller.stock[200], 1);
      expect(needsOf(controller.realNeeds), {5807: 10, 5814: 2, 5827: 5});
    });

    test('남은 소요가 없으면 달성률이 100%가 아니라 0%가 된다', () async {
      final (controller, _, _) = await build(stock: {200: 1, 201: 1, 202: 1});
      addTearDown(controller.dispose);

      expect(controller.realNeeds, isEmpty);
      expect(controller.completionRate, 0.0);
    });
  });
}
