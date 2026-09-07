import 'package:karanda/data_source/lifeskill_mastery_data_source.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_price_data.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/model/trade_market_wait_item.dart';
import 'package:karanda/repository/lifeskill_mastery_repository.dart';
import 'package:karanda/service/trade_market_service.dart';

/// 실제 [TradeMarketService]의 공개 인터페이스만 구현한 가짜.
///
/// 컨트롤러를 그대로 검증하기 위한 것으로, 네트워크·로컬 저장소·WebSocket에
/// 닿지 않는다. 가격은 `{코드}_{강화단계}` 키로 미리 넣어 둔다.
class FakeTradeMarketService implements TradeMarketService {
  final Map<String, TradeMarketTemplate> templates;
  final Map<String, TradeMarketPriceData> prices;

  /// 가격 조회 호출 횟수. 배치 1회 조회를 검증하는 데 쓴다.
  int priceCallCount = 0;

  /// 마지막 조회에 넘어간 키 목록.
  List<String> lastRequestedKeys = const [];

  bool throwOnPriceRequest = false;

  /// 저장(추가/수정)으로 넘어온 템플릿. 에디터 검증에 쓴다.
  final List<TradeMarketTemplate> saved = [];

  /// 슬롯 라벨별 후보 목록. 카탈로그를 읽지 않고 테스트가 직접 지정한다.
  final Map<String, List<TradeMarketTemplateItem>> slotResolutions = {};

  /// 생활별 숙련도와 산출 배율. 에셋을 읽지 않고 테스트가 직접 지정한다.
  final Map<TradeMarketLifeskill, int> mastery = {};
  final Map<TradeMarketLifeskill, double> multipliers = {};

  FakeTradeMarketService({
    this.templates = const {},
    this.prices = const {},
  });

  @override
  Future<TradeMarketTemplate?> getTemplate(String id) async => templates[id];

  @override
  Future<List<TradeMarketPriceData>> getPriceDataByKeys(
    List<String> keys,
    BDORegion region,
  ) async {
    priceCallCount += 1;
    lastRequestedKeys = keys;
    if (throwOnPriceRequest) {
      throw Exception('failed');
    }
    return keys
        .map((key) => prices[key])
        .whereType<TradeMarketPriceData>()
        .toList();
  }

  @override
  Future<TradeMarketTemplate> copyTemplate(
    TradeMarketTemplate source, {
    required String name,
  }) async {
    return source.copyAsUserTemplate(name: name);
  }

  // 이 테스트에서 쓰지 않는 나머지 인터페이스.
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Stream<List<TradeMarketWaitItem>> get waitListStream =>
      const Stream.empty();

  @override
  Stream<List<TradeMarketTemplate>> get templatesStream => const Stream.empty();

  @override
  Future<List<TradeMarketTemplate>> getTemplates() async =>
      templates.values.toList();

  @override
  Future<List<TradeMarketTemplate>> getBuiltInTemplates() async => const [];

  @override
  Future<Map<String, List<TradeMarketPriceData>>> getPriceDetailData(
          String code, BDORegion region) async =>
      const {};

  @override
  Future<void> addTemplate(TradeMarketTemplate template) async {
    saved.add(template);
  }

  @override
  Future<void> updateTemplate(TradeMarketTemplate template) async {
    saved.add(template);
  }

  @override
  Future<List<TradeMarketTemplateItem>> resolveSlot(
          TradeMarketItemSlot slot) async =>
      slotResolutions[slot.label] ?? const [];

  @override
  Future<int> getMastery(TradeMarketLifeskill lifeskill) async =>
      mastery[lifeskill] ?? 0;

  @override
  Future<void> setMastery(TradeMarketLifeskill lifeskill, int value) async {
    mastery[lifeskill] = value;
  }

  @override
  Future<double> outputMultiplierOf(TradeMarketLifeskill lifeskill) async =>
      multipliers[lifeskill] ?? 1.0;

  /// 황납 보너스는 실제 에셋 조회 결과를 그대로 쓴다 —
  /// 요리상자 수익이 리뉴얼 전과 같은지 확인하려면 표를 우회하면 안 된다.
  final LifeskillMasteryRepository _masteryRepository =
      LifeskillMasteryRepository(dataSource: LifeskillMasteryDataSource());

  @override
  Future<double> royalTradeSilverBonusOf(
    TradeMarketLifeskill lifeskill,
    int mastery,
  ) =>
      _masteryRepository.royalTradeSilverBonusOf(lifeskill, mastery);

  @override
  Future<void> deleteTemplate(String id) async {}
}
