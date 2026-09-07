import 'package:flutter/material.dart';
import 'package:karanda/model/bdo_item_info.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/service/bdo_item_info_service.dart';
import 'package:karanda/service/trade_market_service.dart';

/// 편집 화면에서만 사용하는 가변 아이템 모델.
///
/// [TradeMarketTemplateItem]의 수량·산출량은 불변이라 편집 도중 값을 직접
/// 바꿀 수 없으므로, 편집 중에는 지속 [TextEditingController]와 가변 필드를 가진
/// 이 홀더로 상태를 관리하고 저장 시점에 [TradeMarketTemplateItem]으로 변환한다.
class TemplateEditorItem {
  final TradeMarketItemSource source;

  /// 카탈로그에 있는 아이템의 코드. 사용자가 직접 적어 넣은 아이템은 null.
  final int? code;

  /// [code]가 없는 아이템의 표시 이름.
  final String? customName;

  int enhancementLevel;
  TradeMarketTemplateItemRole role;

  final TextEditingController quantityController;
  final TextEditingController yieldController;

  /// 거래소에서 살 수 없는 아이템의 가격. 시세가 없으므로 사용자가 직접 넣는다.
  final TextEditingController priceController;

  TemplateEditorItem({
    this.source = TradeMarketItemSource.market,
    this.code,
    this.customName,
    this.enhancementLevel = 0,
    this.role = TradeMarketTemplateItemRole.material,
    int quantity = 1,
    int yieldAmount = 1,
    int? price,
  })  : quantityController =
            TextEditingController(text: quantity.toString()),
        yieldController = TextEditingController(text: yieldAmount.toString()),
        priceController =
            TextEditingController(text: price == null ? "" : price.toString());

  bool get isOffMarket => source == TradeMarketItemSource.offMarket;

  /// 중복 판정 키. 카탈로그 아이템은 코드+강화 단계, 직접 입력 아이템은 이름으로 구분한다.
  String get identity =>
      code == null ? "custom:${customName ?? ""}" : "$code:$enhancementLevel";

  int get quantity => _positive(quantityController.text);

  int get yieldAmount => _positive(yieldController.text);

  int? get price {
    final value = int.tryParse(priceController.text.replaceAll(",", ""));
    return value == null || value < 0 ? null : value;
  }

  int _positive(String text) {
    final value = int.tryParse(text) ?? 1;
    return value < 1 ? 1 : value;
  }

  TradeMarketTemplateItem toTemplateItem() {
    return TradeMarketTemplateItem(
      source: source,
      code: code,
      customName: customName,
      enhancementLevel: enhancementLevel,
      quantity: quantity,
      yieldAmount: yieldAmount,
      offMarketPrice: isOffMarket ? price : null,
      role: role,
    );
  }

  void dispose() {
    quantityController.dispose();
    yieldController.dispose();
    priceController.dispose();
  }
}

/// 제작법 비교형의 제작법 하나.
///
/// 슬롯·구성 요소 아이템은 화면에서 편집할 수 없으므로 [locked]에 원본 그대로 보관했다가
/// 저장 시 되돌려 놓는다. 그러지 않으면 빌트인을 복제해 편집하는 순간 슬롯이 사라진다.
class TemplateEditorVariant {
  final TextEditingController nameController;
  final List<TemplateEditorItem> items;
  final List<TradeMarketTemplateItem> locked;

  TemplateEditorVariant({
    String name = "",
    List<TemplateEditorItem>? items,
    List<TradeMarketTemplateItem>? locked,
  })  : nameController = TextEditingController(text: name),
        items = items ?? [],
        locked = locked ?? [];

  TradeMarketRecipeVariant toVariant() {
    return TradeMarketRecipeVariant(
      name: nameController.text.trim(),
      items: [...locked, ...items.map((item) => item.toTemplateItem())],
    );
  }

  void dispose() {
    nameController.dispose();
    for (final item in items) {
      item.dispose();
    }
  }
}

class TradeMarketTemplateEditorController extends ChangeNotifier {
  static const int maxItemCount = 100;

  final TradeMarketService _tradeMarketService;
  final BDOItemInfoService _itemInfoService;
  final String? templateId;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController familyFameController =
      TextEditingController(text: "0");
  final List<TemplateEditorItem> items = [];

  /// 제작법 비교형 전용.
  final List<TemplateEditorVariant> variants = [];

  /// 본문 아이템 중 화면에서 편집할 수 없는 것(구성 요소·슬롯). 저장 시 그대로 되돌린다.
  final List<TradeMarketTemplateItem> lockedItems = [];

  TradeMarketTemplateType type = TradeMarketTemplateType.profit;
  TradeMarketLifeskill lifeskill = TradeMarketLifeskill.none;

  bool taxEnabled = false;
  bool valuePackage = false;
  bool merchantRing = false;
  bool crescentPass = false;

  /// 화면이 아직 다루지 않는 필드(제작법 목록 등)를 저장 시 그대로 보존하기 위해 들고 있는다.
  TradeMarketTemplate? _source;

  bool loading = true;

  TradeMarketTemplateEditorController({
    required TradeMarketService tradeMarketService,
    required BDOItemInfoService itemInfoService,
    this.templateId,
  })  : _tradeMarketService = tradeMarketService,
        _itemInfoService = itemInfoService {
    _init();
  }

  bool get isEditMode => templateId != null;

  bool get atCapacity => items.length >= maxItemCount;

  bool get canSave {
    if (nameController.text.trim().isEmpty) {
      return false;
    }
    if (usesVariants) {
      return variants.any((v) => v.items.isNotEmpty || v.locked.isNotEmpty);
    }
    return items.isNotEmpty || lockedItems.isNotEmpty;
  }

  /// 역할(재료/결과물)은 차익형에서만 의미가 있다.
  bool get usesRole => type == TradeMarketTemplateType.profit;

  /// 산출량은 단가 비교형에서만 쓰고, 나머지 타입은 수량을 쓴다.
  bool get usesYield => type == TradeMarketTemplateType.unitPrice;

  bool get usesQuantity => !usesYield;

  /// 수수료·생활 종류는 결과물 개념이 있는 차익형에서만 노출한다.
  bool get usesTaxAndLifeskill => type == TradeMarketTemplateType.profit;

  /// 이름 입력 등 컨트롤러 외부 상태 변화 시 UI(저장 버튼 활성화 등)를 갱신한다.
  void refresh() => notifyListeners();

  Future<void> _init() async {
    if (templateId != null) {
      final template = await _tradeMarketService.getTemplate(templateId!);
      if (template != null) {
        _source = template;
        nameController.text = template.name;
        type = template.type;
        lifeskill = template.lifeskill;
        taxEnabled = template.tax.enabled;
        valuePackage = template.tax.valuePackage;
        merchantRing = template.tax.merchantRing;
        crescentPass = template.tax.crescentPass;
        familyFameController.text = template.tax.familyFame.toString();
        for (final item in template.items) {
          // 슬롯·구성 요소는 편집 대상이 아니므로 원본을 보관만 한다.
          if (_isLocked(item)) {
            lockedItems.add(item);
            continue;
          }
          items.add(_toEditorItem(item));
        }
        for (final variant in template.variants) {
          variants.add(TemplateEditorVariant(
            name: variant.name,
            items: variant.items
                .where((item) => !_isLocked(item))
                .map(_toEditorItem)
                .toList(),
            locked: variant.items.where(_isLocked).toList(),
          ));
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  /// 슬롯이나 구성 요소를 가진 아이템은 화면에서 편집할 수 없다.
  static bool _isLocked(TradeMarketTemplateItem item) =>
      item.slot != null || item.components.isNotEmpty;

  static TemplateEditorItem _toEditorItem(TradeMarketTemplateItem item) {
    return TemplateEditorItem(
      source: item.source,
      code: item.code,
      customName: item.customName,
      enhancementLevel: item.enhancementLevel,
      role: item.role,
      quantity: item.quantity,
      yieldAmount: item.yieldAmount,
      price: item.offMarketPrice,
    );
  }

  bool get usesVariants => type == TradeMarketTemplateType.recipeCompare;

  void addVariant() {
    variants.add(TemplateEditorVariant());
    notifyListeners();
  }

  void removeVariant(TemplateEditorVariant variant) {
    variants.remove(variant);
    variant.dispose();
    notifyListeners();
  }

  /// 제작법에 아이템을 추가한다. 중복 판정은 제작법 안에서만 한다.
  bool addItemToVariant(TemplateEditorVariant variant, BDOItemInfo itemInfo) {
    final code = int.tryParse(itemInfo.code);
    if (code == null || variant.items.length >= maxItemCount) {
      return false;
    }
    final item = TemplateEditorItem(
      source: itemInfo.tradeAble
          ? TradeMarketItemSource.market
          : TradeMarketItemSource.offMarket,
      code: code,
    );
    if (variant.items.any((other) => other.identity == item.identity)) {
      item.dispose();
      return false;
    }
    variant.items.add(item);
    notifyListeners();
    return true;
  }

  void removeItemFromVariant(
    TemplateEditorVariant variant,
    TemplateEditorItem item,
  ) {
    variant.items.remove(item);
    item.dispose();
    notifyListeners();
  }

  void updateType(TradeMarketTemplateType value) {
    if (type == value) {
      return;
    }
    type = value;
    notifyListeners();
  }

  void updateLifeskill(TradeMarketLifeskill value) {
    lifeskill = value;
    notifyListeners();
  }

  void updateTaxEnabled(bool value) {
    taxEnabled = value;
    notifyListeners();
  }

  void updateValuePackage(bool value) {
    valuePackage = value;
    notifyListeners();
  }

  void updateMerchantRing(bool value) {
    merchantRing = value;
    notifyListeners();
  }

  void updateCrescentPass(bool value) {
    crescentPass = value;
    notifyListeners();
  }

  /// 자동완성 옵션. **거래 불가 아이템도 포함**한다 —
  /// 템플릿에는 거래소에서 살 수 없는 아이템도 들어가기 때문이다.
  List<BDOItemInfo> searchItems(String value, Locale locale) {
    final query = value.replaceAll(" ", "").toLowerCase();
    if (query.isEmpty) {
      return const [];
    }
    return _itemInfoService.items
        .where((item) =>
            item.name(locale).replaceAll(" ", "").toLowerCase().contains(query))
        .toList();
  }

  /// 최대 강화 단계. 강화 불가 아이템은 0.
  int maxEnhancementOf(int code) {
    return _itemInfoService.itemInfo(code.toString()).maxEnhancement;
  }

  /// 자동완성에서 선택한 아이템을 템플릿에 추가한다. 성공 시 true.
  bool addItem(BDOItemInfo itemInfo) {
    final code = int.tryParse(itemInfo.code);
    if (code == null) {
      return false;
    }
    // 거래 불가 아이템은 시세가 없으므로 가격을 직접 넣는 항목으로 추가한다.
    return _add(TemplateEditorItem(
      source: itemInfo.tradeAble
          ? TradeMarketItemSource.market
          : TradeMarketItemSource.offMarket,
      code: code,
      role: TradeMarketTemplateItemRole.material,
    ));
  }

  /// 카탈로그에 아예 없는 아이템을 이름·가격으로 직접 추가한다.
  bool addCustomItem(String name, int price) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    return _add(TemplateEditorItem(
      source: TradeMarketItemSource.offMarket,
      customName: trimmed,
      price: price,
      role: TradeMarketTemplateItemRole.material,
    ));
  }

  bool _add(TemplateEditorItem item) {
    if (atCapacity) {
      return false;
    }
    if (items.any((other) => other.identity == item.identity)) {
      item.dispose();
      return false;
    }
    items.add(item);
    notifyListeners();
    return true;
  }

  void removeItem(TemplateEditorItem item) {
    items.remove(item);
    item.dispose();
    notifyListeners();
  }

  void updateRole(TemplateEditorItem item, TradeMarketTemplateItemRole role) {
    item.role = role;
    notifyListeners();
  }

  /// 아이템 강화 단계를 변경한다. 같은 코드/단계 조합이 이미 있으면 무시하고 false.
  bool updateEnhancement(TemplateEditorItem item, int level) {
    if (item.enhancementLevel == level) {
      return true;
    }
    final next = "${item.code}:$level";
    if (items.any((other) => other != item && other.identity == next)) {
      return false;
    }
    item.enhancementLevel = level;
    notifyListeners();
    return true;
  }

  Future<bool> save() async {
    if (!canSave) {
      return false;
    }
    final source = _source;
    final template = TradeMarketTemplate(
      id: templateId,
      name: nameController.text.trim(),
      type: type,
      tax: TradeMarketTaxOption(
        enabled: taxEnabled,
        valuePackage: valuePackage,
        merchantRing: merchantRing,
        crescentPass: crescentPass,
        familyFame: int.tryParse(familyFameController.text) ?? 0,
      ),
      lifeskill: lifeskill,
      items: [...lockedItems, ...items.map((item) => item.toTemplateItem())],
      variants: variants.map((variant) => variant.toVariant()).toList(),
    );
    if (isEditMode) {
      await _tradeMarketService.updateTemplate(template);
    } else {
      await _tradeMarketService.addTemplate(template);
    }
    return true;
  }

  Future<void> delete() async {
    if (templateId != null) {
      await _tradeMarketService.deleteTemplate(templateId!);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    familyFameController.dispose();
    for (final item in items) {
      item.dispose();
    }
    for (final variant in variants) {
      variant.dispose();
    }
    super.dispose();
  }
}
