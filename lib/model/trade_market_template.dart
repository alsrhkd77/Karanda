import 'package:karanda/model/trade_market_price_data.dart';
import 'package:uuid/uuid.dart';

/// 템플릿 계산 방식.
///
/// 하나의 템플릿으로 모든 계산을 커버할 수 없어 타입으로 나눈다.
/// 타입마다 아이템의 `quantity`/`yieldAmount` 중 어느 쪽을 쓰는지가 다르다.
enum TradeMarketTemplateType {
  /// 단가 비교형. `가격 ÷ yieldAmount` 오름차순. (기존 고정 프리셋)
  unitPrice,

  /// 준비물 총액형. `가격 × quantity` 합계.
  shoppingList,

  /// 재료→결과물 차익형. 역할별 합계와 차익.
  profit,

  /// 제작법 비교형. 제작법(variant)별 총 원가를 비교한다.
  recipeCompare;

  static TradeMarketTemplateType fromName(String? name) {
    return TradeMarketTemplateType.values.firstWhere(
      (type) => type.name == name,
      // 타입 도입 이전에 저장된 템플릿은 모두 차익형이었다.
      orElse: () => TradeMarketTemplateType.profit,
    );
  }
}

/// 결과물 산출량에 영향을 주는 생활 종류. 숙련도 테이블 선택에 쓰인다.
enum TradeMarketLifeskill {
  none,
  cooking,
  alchemy,
  processing;

  static TradeMarketLifeskill fromName(String? name) {
    return TradeMarketLifeskill.values.firstWhere(
      (value) => value.name == name,
      orElse: () => TradeMarketLifeskill.none,
    );
  }
}

/// 아이템 가격의 출처.
enum TradeMarketItemSource {
  /// 거래소 거래 가능. 최신가를 조회한다.
  market,

  /// 거래소에 없지만 구성 요소로 가격을 계산할 수 있는 아이템.
  /// (예: 카프라스 돌파 우두머리 무기 = 동 우두머리 무기 + 카프라스의 돌 × N)
  derived,

  /// 거래소에도 없고 계산도 불가능한 아이템. 기본값 또는 사용자 입력 가격을 쓴다.
  offMarket;

  static TradeMarketItemSource fromName(String? name) {
    return TradeMarketItemSource.values.firstWhere(
      (value) => value.name == name,
      orElse: () => TradeMarketItemSource.market,
    );
  }
}

enum TradeMarketTemplateItemRole {
  material,
  result;

  static TradeMarketTemplateItemRole fromName(String? name) {
    return TradeMarketTemplateItemRole.values.firstWhere(
      (role) => role.name == name,
      orElse: () => TradeMarketTemplateItemRole.material,
    );
  }
}

/// 거래소 판매 수수료 옵션. 차익형(`profit`)에서 결과물 합계에만 적용한다.
///
/// 게임 사양(2026-08-17 확인):
/// - 수수료는 **35% 고정**이라 기본 수령액은 판매액의 **65%**다.
/// - 추가 수령액은 **판매액이 아니라 기본 수령액에 곱해지고**, 항목끼리는 **합연산**이다.
///   밸류 패키지 +30%, 거상의 반지 +5%, 그믐달 거래 우대권 +5%,
///   가문 명성 1000 이상 +0.5% / 4000 이상 +1% / 7000 이상 +1.5%.
/// - 즉 `최종 수령액 = 판매액 × 0.65 × (1 + 추가 수령액 합)`.
///   (예: 밸류 패키지 + 가문 명성 7000 → `× 0.65 × 1.315`)
///
/// 계수는 패치 이력이 있으므로 이 클래스 한곳에만 둔다.
class TradeMarketTaxOption {
  /// 수수료 35%를 뗀 기본 수령 비율.
  static const double baseReceiptRate = 0.65;

  static const double valuePackageBonus = 0.30;
  static const double merchantRingBonus = 0.05;
  static const double crescentPassBonus = 0.05;

  /// 가문 명성 구간별 추가 수령 비율. 구간 경계값을 포함한다.
  static double familyFameBonusOf(int fame) {
    if (fame >= 7000) {
      return 0.015;
    }
    if (fame >= 4000) {
      return 0.01;
    }
    if (fame >= 1000) {
      return 0.005;
    }
    return 0.0;
  }

  /// 수수료 반영 여부. 타입 도입 이전 템플릿은 미적용으로 읽어 기존 수치를 유지한다.
  final bool enabled;

  /// 밸류 패키지
  final bool valuePackage;

  /// 거상의 반지
  final bool merchantRing;

  /// 그믐달 거래 우대권
  final bool crescentPass;

  /// 가문 명성
  final int familyFame;

  const TradeMarketTaxOption({
    this.enabled = false,
    this.valuePackage = false,
    this.merchantRing = false,
    this.crescentPass = false,
    this.familyFame = 0,
  });

  /// 추가 수령 비율의 합. 각 항목은 합연산이다.
  double get bonusRate {
    double bonus = familyFameBonusOf(familyFame);
    if (valuePackage) {
      bonus += valuePackageBonus;
    }
    if (merchantRing) {
      bonus += merchantRingBonus;
    }
    if (crescentPass) {
      bonus += crescentPassBonus;
    }
    return bonus;
  }

  /// 판매액에 곱할 최종 수령 비율. 미적용이면 1.0이라 기존 수치가 그대로 유지된다.
  double get receiptRate =>
      enabled ? baseReceiptRate * (1 + bonusRate) : 1.0;

  /// 판매액에서 실제로 손에 들어오는 금액.
  int receiptOf(int saleAmount) => (saleAmount * receiptRate).round();

  /// 수수료로 빠지는 금액.
  int feeOf(int saleAmount) => saleAmount - receiptOf(saleAmount);

  factory TradeMarketTaxOption.fromJson(Map json) {
    return TradeMarketTaxOption(
      enabled: json["enabled"] ?? false,
      valuePackage: json["value package"] ?? false,
      merchantRing: json["merchant ring"] ?? false,
      crescentPass: json["crescent pass"] ?? false,
      familyFame: json["family fame"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "enabled": enabled,
      "value package": valuePackage,
      "merchant ring": merchantRing,
      "crescent pass": crescentPass,
      "family fame": familyFame,
    };
  }
}

/// 후보 여럿 중 **총원가가 가장 싼 것을 앱이 자동으로 고르는** 자리.
///
/// 군왕 무기는 자기 클래스 장비를 쓸 필요가 없고 카테고리만 맞으면 되므로,
/// 사용자가 무기 종류를 고르는 대신 카테고리 전체를 조회해 최저가를 찾는다.
class TradeMarketItemSlot {
  /// 표시 이름(빌트인은 i18n 키).
  final String label;
  final List<TradeMarketSlotCandidate> candidates;

  const TradeMarketItemSlot({
    this.label = "",
    this.candidates = const [],
  });

  factory TradeMarketItemSlot.fromJson(Map json) {
    return TradeMarketItemSlot(
      label: json["label"] ?? "",
      candidates: (json["candidates"] as List?)
              ?.map((item) => TradeMarketSlotCandidate.fromJson(item))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "label": label,
      "candidates": candidates.map((item) => item.toJson()).toList(),
    };
  }
}

/// 슬롯 후보 한 묶음. 카탈로그에서 실제 아이템 목록으로 펼쳐진다.
class TradeMarketSlotCandidate {
  /// 검색 범위. prefix 매칭은 **반드시 이 값으로 좁힌다**(동명 재료 혼입 방지).
  final int mainCategory;

  /// 규칙형 판정. 신규 직업이 추가돼도 카탈로그만 갱신되면 자동으로 포함된다.
  final List<String> prefixes;

  /// 명시형 판정. 이름 규칙이 없는 방어구용.
  final List<int> codes;

  final int enhancementLevel;

  /// 0보다 크면 카프라스 돌파 장비다. 장비별 누적 개수를 카프라스의 돌 가격과 곱해 더한다.
  /// 카프라스 돌파 장비는 거래소에 등록하면 개방치가 초기화되므로 직접 살 수 없다.
  final int caphrasLevel;

  const TradeMarketSlotCandidate({
    this.mainCategory = 0,
    this.prefixes = const [],
    this.codes = const [],
    this.enhancementLevel = 0,
    this.caphrasLevel = 0,
  });

  factory TradeMarketSlotCandidate.fromJson(Map json) {
    return TradeMarketSlotCandidate(
      mainCategory: json["main category"] ?? 0,
      prefixes: (json["prefixes"] as List?)?.cast<String>() ?? const [],
      codes: (json["codes"] as List?)?.cast<int>() ?? const [],
      enhancementLevel: json["enhancement level"] ?? 0,
      caphrasLevel: json["caphras level"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "main category": mainCategory,
      "prefixes": prefixes,
      "codes": codes,
      "enhancement level": enhancementLevel,
      "caphras level": caphrasLevel,
    };
  }
}

/// 템플릿에 담기는 아이템 한 줄.
///
/// 거래소 아이템뿐 아니라 거래 불가 아이템(사용자가 직접 이름·가격을 입력한 것 포함)과
/// 구성 요소로 가격을 계산하는 아이템까지 같은 모델로 표현한다.
class TradeMarketTemplateItem {
  final TradeMarketItemSource source;

  /// 아이템 코드. 카탈로그에 없는 사용자 정의 아이템은 null.
  final int? code;

  /// [code]가 null일 때의 표시 이름. 빌트인 템플릿은 i18n 키를 담는다.
  final String? customName;

  final int enhancementLevel;

  /// 필요 수량. `shoppingList`·`profit`·`recipeCompare`에서 사용한다.
  final int quantity;

  /// 이 아이템 1개가 만들어 내는 산출량. `unitPrice`에서 사용한다.
  final int yieldAmount;

  /// [TradeMarketItemSource.offMarket] 아이템의 가격.
  /// 빌트인이 제공하는 기본값이거나 사용자가 입력한 값이다.
  final int? offMarketPrice;

  /// [TradeMarketItemSource.derived] 아이템의 구성 요소.
  ///
  /// 깊이는 1단계로 제한한다 — 여기에 다시 `derived`를 넣지 않는다.
  /// 중첩을 허용하면 조회가 반복되고 순환 참조 위험이 생긴다.
  final List<TradeMarketTemplateItem> components;

  /// `profit`에서만 유효하다.
  final TradeMarketTemplateItemRole role;

  /// 최저가 슬롯. 지정되면 [code]/[customName] 대신 후보 중 최저 총원가가 쓰인다.
  final TradeMarketItemSlot? slot;

  /// 조회한 거래소 최신가. 영속되지 않는 런타임 값.
  TradeMarketPriceData? marketPrice;

  /// 슬롯에서 최저가로 뽑힌 후보. 영속되지 않는 런타임 값.
  TradeMarketTemplateItem? slotResolution;

  TradeMarketTemplateItem({
    this.source = TradeMarketItemSource.market,
    this.code,
    this.customName,
    this.enhancementLevel = 0,
    this.quantity = 1,
    this.yieldAmount = 1,
    this.offMarketPrice,
    this.components = const [],
    this.role = TradeMarketTemplateItemRole.material,
    this.slot,
  });

  /// 최신가 조회 키. 코드가 없는 사용자 정의 아이템은 null.
  String? get key => code == null ? null : "${code}_$enhancementLevel";

  /// 거래소 조회가 필요한 아이템인지. `offMarket`은 조회 대상에서 제외한다.
  /// 슬롯은 후보를 따로 펼쳐 조회하므로 자기 자신은 대상이 아니다.
  bool get needsMarketPrice =>
      slot == null && source == TradeMarketItemSource.market;

  /// 아이템 1개 가격. 아직 조회되지 않았으면 null.
  int? get unitCost {
    if (slot != null) {
      return slotResolution?.totalCost;
    }
    switch (source) {
      case TradeMarketItemSource.market:
        return marketPrice?.price;
      case TradeMarketItemSource.offMarket:
        return offMarketPrice;
      case TradeMarketItemSource.derived:
        int total = 0;
        for (final component in components) {
          final cost = component.totalCost;
          if (cost == null) {
            return null;
          }
          total += cost;
        }
        return total;
    }
  }

  /// 수량까지 반영한 가격. 아직 조회되지 않았으면 null.
  int? get totalCost {
    final unit = unitCost;
    return unit == null ? null : unit * quantity;
  }

  /// 조회가 필요한 모든 아이템(구성 요소 포함)을 평탄화해 반환한다.
  /// 한 템플릿의 모든 코드를 모아 최신가를 **한 번에** 조회하기 위한 것이다.
  Iterable<TradeMarketTemplateItem> get flattened sync* {
    yield this;
    for (final component in components) {
      yield* component.flattened;
    }
  }

  factory TradeMarketTemplateItem.fromJson(Map json) {
    return TradeMarketTemplateItem(
      source: TradeMarketItemSource.fromName(json["source"]),
      code: json["code"],
      customName: json["custom name"],
      enhancementLevel: json["enhancement level"] ?? 0,
      // 타입 도입 이전에는 수량·산출량을 구분 없이 `value` 하나로 저장했다.
      quantity: json["quantity"] ?? json["value"] ?? 1,
      yieldAmount: json["yield amount"] ?? json["value"] ?? 1,
      offMarketPrice: json["off market price"],
      components: (json["components"] as List?)
              ?.map((item) => TradeMarketTemplateItem.fromJson(item))
              .toList() ??
          const [],
      role: TradeMarketTemplateItemRole.fromName(json["role"]),
      slot: json["slot"] == null
          ? null
          : TradeMarketItemSlot.fromJson(json["slot"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "source": source.name,
      "code": code,
      "custom name": customName,
      "enhancement level": enhancementLevel,
      "quantity": quantity,
      "yield amount": yieldAmount,
      "off market price": offMarketPrice,
      "components": components.map((item) => item.toJson()).toList(),
      "role": role.name,
      "slot": slot?.toJson(),
    };
  }
}

/// `recipeCompare`에서 비교 대상이 되는 제작법 하나.
class TradeMarketRecipeVariant {
  /// 표시 이름. 빌트인은 i18n 키를 담는다.
  final String name;
  final List<TradeMarketTemplateItem> items;

  const TradeMarketRecipeVariant({
    required this.name,
    required this.items,
  });

  factory TradeMarketRecipeVariant.fromJson(Map json) {
    return TradeMarketRecipeVariant(
      name: json["name"] ?? "",
      items: (json["items"] as List?)
              ?.map((item) => TradeMarketTemplateItem.fromJson(item))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "items": items.map((item) => item.toJson()).toList(),
    };
  }
}

class TradeMarketTemplate {
  /// 빌트인은 에셋 키(`melody_of_stars` 등), 사용자 생성은 uuid v7.
  /// 빌트인 키가 곧 i18n 키이자 라우트 경로가 된다.
  final String id;
  final String name;
  final TradeMarketTemplateType type;
  final TradeMarketTaxOption tax;
  final TradeMarketLifeskill lifeskill;

  /// `recipeCompare`를 제외한 타입의 아이템 목록.
  final List<TradeMarketTemplateItem> items;

  /// `recipeCompare`의 제작법 목록.
  final List<TradeMarketRecipeVariant> variants;

  /// 앱이 기본 제공하는 템플릿인지. 원본은 읽기 전용이며 복제해서만 편집한다.
  /// 에셋에서 읽을 때만 true가 되고 사용자 저장소에는 남지 않는다.
  final bool isBuiltIn;

  TradeMarketTemplate({
    String? id,
    required this.name,
    this.type = TradeMarketTemplateType.profit,
    this.tax = const TradeMarketTaxOption(),
    this.lifeskill = TradeMarketLifeskill.none,
    this.items = const [],
    this.variants = const [],
    this.isBuiltIn = false,
  }) : id = id ?? const Uuid().v7();

  List<TradeMarketTemplateItem> get materials => items
      .where((item) => item.role == TradeMarketTemplateItemRole.material)
      .toList();

  List<TradeMarketTemplateItem> get results => items
      .where((item) => item.role == TradeMarketTemplateItemRole.result)
      .toList();

  /// 템플릿 전체에서 최신가 조회가 필요한 아이템.
  /// 구성 요소와 제작법까지 모두 훑어 **한 번의 배치 조회**로 처리하기 위한 목록이다.
  List<TradeMarketTemplateItem> get marketItems {
    final result = <TradeMarketTemplateItem>[];
    for (final item in items) {
      result.addAll(item.flattened.where((item) => item.needsMarketPrice));
    }
    for (final variant in variants) {
      for (final item in variant.items) {
        result.addAll(item.flattened.where((item) => item.needsMarketPrice));
      }
    }
    return result;
  }

  factory TradeMarketTemplate.fromJson(Map json, {bool isBuiltIn = false}) {
    return TradeMarketTemplate(
      id: json["id"],
      name: json["name"],
      type: TradeMarketTemplateType.fromName(json["type"]),
      tax: json["tax"] == null
          ? const TradeMarketTaxOption()
          : TradeMarketTaxOption.fromJson(json["tax"]),
      lifeskill: TradeMarketLifeskill.fromName(json["lifeskill"]),
      items: (json["items"] as List?)
              ?.map((item) => TradeMarketTemplateItem.fromJson(item))
              .toList() ??
          [],
      variants: (json["variants"] as List?)
              ?.map((item) => TradeMarketRecipeVariant.fromJson(item))
              .toList() ??
          const [],
      isBuiltIn: isBuiltIn,
    );
  }

  /// 사용자 저장소에 기록할 형식. [isBuiltIn]은 저장하지 않는다.
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "type": type.name,
      "tax": tax.toJson(),
      "lifeskill": lifeskill.name,
      "items": items.map((item) => item.toJson()).toList(),
      "variants": variants.map((variant) => variant.toJson()).toList(),
    };
  }

  /// 빌트인을 "내 템플릿"으로 복제한다. 새 id를 받고 편집 가능해진다.
  TradeMarketTemplate copyAsUserTemplate({required String name}) {
    return TradeMarketTemplate(
      name: name,
      type: type,
      tax: tax,
      lifeskill: lifeskill,
      items: items
          .map((item) => TradeMarketTemplateItem.fromJson(item.toJson()))
          .toList(),
      variants: variants
          .map((variant) =>
              TradeMarketRecipeVariant.fromJson(variant.toJson()))
          .toList(),
    );
  }
}
