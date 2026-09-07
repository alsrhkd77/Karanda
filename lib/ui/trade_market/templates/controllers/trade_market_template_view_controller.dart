import 'package:flutter/foundation.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/service/trade_market_service.dart';

class TradeMarketTemplateViewController extends ChangeNotifier {
  final TradeMarketService _tradeMarketService;
  final BDORegion region;
  final String templateId;

  TradeMarketTemplate? template;

  TradeMarketTemplateViewController({
    required TradeMarketService tradeMarketService,
    required this.templateId,
    required this.region,
  }) : _tradeMarketService = tradeMarketService {
    _getBaseData();
  }

  bool get notFound => _notFound;
  bool _notFound = false;

  bool get hasError => _hasError;
  bool _hasError = false;

  TradeMarketTemplateType get type =>
      template?.type ?? TradeMarketTemplateType.profit;

  bool get isBuiltIn => template?.isBuiltIn ?? false;

  List<TradeMarketTemplateItem> get items => template?.items ?? const [];

  List<TradeMarketTemplateItem>? get materials => template?.materials;

  List<TradeMarketTemplateItem>? get results => template?.results;

  /// 슬롯별로 펼쳐진 후보. 최저가만 남기지 않고 전부 들고 있는다 —
  /// 어차피 최저가를 알려면 전부 조회해야 하므로 버릴 이유가 없고,
  /// 화면에서 "왜 그게 골라졌는지"를 보여줄 수 있다.
  final Map<TradeMarketTemplateItem, List<TradeMarketTemplateItem>>
      slotCandidates = {};

  List<TradeMarketRecipeVariant> get variants => template?.variants ?? const [];

  bool get isLoaded {
    final current = template;
    if (current == null) {
      return false;
    }
    return _allItems.every((item) => item.unitCost != null);
  }

  /// 템플릿이 담고 있는 모든 아이템(제작법 포함).
  List<TradeMarketTemplateItem> get _allItems {
    final current = template;
    if (current == null) {
      return const [];
    }
    return [
      ...current.items,
      for (final variant in current.variants) ...variant.items,
    ];
  }

  /// 제작법 하나의 총 원가. 후보 조회 전이면 null.
  int? variantTotal(TradeMarketRecipeVariant variant) {
    int total = 0;
    for (final item in variant.items) {
      final cost = item.totalCost;
      if (cost == null) {
        return null;
      }
      total += cost;
    }
    return total;
  }

  /// 총 원가가 가장 싼 제작법. 계산 가능한 제작법이 없으면 null.
  TradeMarketRecipeVariant? get cheapestVariant {
    TradeMarketRecipeVariant? best;
    int? bestTotal;
    for (final variant in variants) {
      final total = variantTotal(variant);
      if (total == null) {
        continue;
      }
      if (bestTotal == null || total < bestTotal) {
        best = variant;
        bestTotal = total;
      }
    }
    return best;
  }

  /// 최저가 제작법과의 차액. 최저가 제작법 자신은 0.
  int? variantExtraCost(TradeMarketRecipeVariant variant) {
    final total = variantTotal(variant);
    final best = cheapestVariant;
    final bestTotal = best == null ? null : variantTotal(best);
    if (total == null || bestTotal == null) {
      return null;
    }
    return total - bestTotal;
  }

  /// 단가 비교형 정렬. 재고 유무가 같으면 단가 오름차순, 다르면 재고 있는 쪽이 앞.
  /// 싸도 물량이 없으면 살 수 없으므로 재고를 우선한다(기존 프리셋과 같은 규칙).
  List<TradeMarketTemplateItem> get sortedByUnitPrice {
    final result = List<TradeMarketTemplateItem>.from(items);
    result.sort((a, b) {
      final aInStock = inStock(a);
      final bInStock = inStock(b);
      if (aInStock != bInStock) {
        return aInStock ? -1 : 1;
      }
      final aUnit = unitPriceOf(a);
      final bUnit = unitPriceOf(b);
      if (aUnit == null || bUnit == null) {
        return aUnit == null ? 1 : -1;
      }
      return aUnit.compareTo(bUnit);
    });
    return result;
  }

  /// 산출 1개당 가격. 조회 전이면 null.
  int? unitPriceOf(TradeMarketTemplateItem item) {
    final cost = item.unitCost;
    if (cost == null) {
      return null;
    }
    final divisor = item.yieldAmount < 1 ? 1 : item.yieldAmount;
    return (cost / divisor).round();
  }

  /// 거래소 재고가 있는지.
  ///
  /// 구성 요소로 만들어지는 아이템은 **구성 요소가 전부 있어야** 살 수 있으므로
  /// 하나라도 품절이면 품절로 본다. 거래소와 무관한 아이템은 재고 개념이 없어 true다.
  bool inStock(TradeMarketTemplateItem item) {
    final resolved = item.slotResolution;
    if (resolved != null) {
      return inStock(resolved);
    }
    if (item.components.isNotEmpty) {
      return item.components.every(inStock);
    }
    if (!item.needsMarketPrice) {
      return true;
    }
    return (item.marketPrice?.currentStock ?? 0) > 0;
  }

  /// 준비물 총액형 합계.
  int get total => _sum(items);

  int get materialsTotal => _sum(template?.materials);

  /// 숙련도에 따른 결과물 산출 배율. 생활을 지정하지 않은 템플릿은 1.0이다.
  double outputMultiplier = 1.0;

  /// 사용자가 입력해 둔 생활 숙련도.
  int mastery = 0;

  /// 결과물 판매액(세전). 숙련도 산출 배율까지 반영한 값이다.
  int get resultsTotal =>
      (_sum(template?.results) * outputMultiplier).round();

  /// 수수료를 뗀 실제 수령액.
  int get resultsReceipt =>
      template?.tax.receiptOf(resultsTotal) ?? resultsTotal;

  /// 수수료로 빠지는 금액.
  int get marketFee => resultsTotal - resultsReceipt;

  /// 차익(세후). 수수료 미적용 템플릿에서는 세전과 같다.
  int get difference => resultsReceipt - materialsTotal;

  /// 차익(세전).
  int get differenceBeforeTax => resultsTotal - materialsTotal;

  /// 수수료 적용 여부. 미적용 템플릿은 요약에서 수수료 줄을 감춘다.
  bool get taxApplied => template?.tax.enabled ?? false;

  TradeMarketLifeskill get lifeskill =>
      template?.lifeskill ?? TradeMarketLifeskill.none;

  int _sum(List<TradeMarketTemplateItem>? items) {
    if (items == null) {
      return 0;
    }
    return items.fold<int>(0, (sum, item) => sum + (item.totalCost ?? 0));
  }

  Future<void> _getBaseData() async {
    template = await _tradeMarketService.getTemplate(templateId);
    if (template == null) {
      _notFound = true;
      notifyListeners();
      return;
    }
    await _loadMastery();
    await _resolveSlots();
    notifyListeners();
    _getPriceData();
  }

  Future<void> _loadMastery() async {
    final skill = lifeskill;
    if (skill == TradeMarketLifeskill.none) {
      mastery = 0;
      outputMultiplier = 1.0;
      return;
    }
    mastery = await _tradeMarketService.getMastery(skill);
    outputMultiplier = await _tradeMarketService.outputMultiplierOf(skill);
  }

  /// 숙련도를 바꾼다. **같은 생활을 쓰는 모든 템플릿에 반영된다.**
  Future<void> updateMastery(int value) async {
    final skill = lifeskill;
    if (skill == TradeMarketLifeskill.none) {
      return;
    }
    await _tradeMarketService.setMastery(skill, value);
    await _loadMastery();
    notifyListeners();
  }

  /// 수수료 조건을 바꾼다. **이 템플릿에만 적용된다.**
  Future<void> updateTax(TradeMarketTaxOption tax) async {
    final current = template;
    if (current == null || current.isBuiltIn) {
      return;
    }
    final next = TradeMarketTemplate(
      id: current.id,
      name: current.name,
      type: current.type,
      tax: tax,
      lifeskill: current.lifeskill,
      items: current.items,
      variants: current.variants,
    );
    await _tradeMarketService.updateTemplate(next);
    template = next;
    notifyListeners();
  }

  /// 슬롯을 카탈로그의 실제 아이템 목록으로 펼친다. 가격 조회 전에 끝나야 한다.
  Future<void> _resolveSlots() async {
    slotCandidates.clear();
    for (final item in _allItems) {
      final slot = item.slot;
      if (slot == null) {
        continue;
      }
      slotCandidates[item] = await _tradeMarketService.resolveSlot(slot);
    }
  }

  /// 조회가 필요한 아이템 전체 — 템플릿 본문 + 제작법 + 슬롯 후보.
  List<TradeMarketTemplateItem> get _priceTargets {
    final result = <TradeMarketTemplateItem>[
      ...?template?.marketItems,
    ];
    for (final candidates in slotCandidates.values) {
      for (final candidate in candidates) {
        result.addAll(candidate.flattened.where((i) => i.needsMarketPrice));
      }
    }
    return result;
  }

  Future<void> _getPriceData() async {
    final marketItems = _priceTargets;
    if (marketItems.isEmpty) {
      return;
    }
    try {
      // 구성 요소와 슬롯 후보까지 모든 코드를 모아 한 번에 조회한다.
      final keys = marketItems
          .map((item) => item.key)
          .whereType<String>()
          .toSet()
          .toList();
      final prices = await _tradeMarketService.getPriceDataByKeys(keys, region);
      final byKey = {for (final price in prices) price.key: price};
      for (TradeMarketTemplateItem item in marketItems) {
        item.marketPrice = byKey[item.key];
      }
      _pickCheapestCandidates();
      _hasError = false;
      notifyListeners();
    } catch (e) {
      _hasError = true;
      notifyListeners();
    }
  }

  /// 슬롯마다 최저 총원가 후보를 고른다.
  /// 재고가 없으면 실제로 살 수 없으므로 재고 있는 후보를 우선한다.
  void _pickCheapestCandidates() {
    for (final entry in slotCandidates.entries) {
      TradeMarketTemplateItem? best;
      for (final candidate in entry.value) {
        if (candidate.totalCost == null) {
          continue;
        }
        if (best == null || _isBetter(candidate, best)) {
          best = candidate;
        }
      }
      entry.key.slotResolution = best;
    }
  }

  bool _isBetter(TradeMarketTemplateItem a, TradeMarketTemplateItem b) {
    final aStock = inStock(a);
    final bStock = inStock(b);
    if (aStock != bStock) {
      return aStock;
    }
    return (a.totalCost ?? 0) < (b.totalCost ?? 0);
  }

  /// 가격 조회 실패 후 재시도한다.
  Future<void> retry() async {
    _hasError = false;
    for (final item in _priceTargets) {
      item.marketPrice = null;
    }
    notifyListeners();
    await _getPriceData();
  }

  /// 빌트인을 내 템플릿으로 복제한다. 복제본 id를 반환한다.
  Future<String?> copyToMyTemplates(String name) async {
    final source = template;
    if (source == null) {
      return null;
    }
    final copied = await _tradeMarketService.copyTemplate(source, name: name);
    return copied.id;
  }
}
