import 'package:flutter/material.dart';
import 'package:karanda/model/bdo_item_info.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/service/bdo_item_info_service.dart';
import 'package:karanda/service/trade_market_service.dart';

/// 편집 화면에서만 사용하는 가변 아이템 모델.
///
/// [TradeMarketTemplateItem]의 `value`(수량)는 불변이라 편집 도중 값을 직접
/// 바꿀 수 없으므로, 편집 중에는 지속 [TextEditingController]와 가변 필드를 가진
/// 이 홀더로 상태를 관리하고 저장 시점에 [TradeMarketTemplateItem]으로 변환한다.
class TemplateEditorItem {
  final int code;
  int enhancementLevel;
  TradeMarketTemplateItemRole role;
  final TextEditingController quantityController;

  TemplateEditorItem({
    required this.code,
    required this.enhancementLevel,
    required this.role,
    required int quantity,
  }) : quantityController = TextEditingController(text: quantity.toString());

  int get quantity {
    final value = int.tryParse(quantityController.text) ?? 1;
    return value < 1 ? 1 : value;
  }

  TradeMarketTemplateItem toTemplateItem() {
    return TradeMarketTemplateItem(
      code: code,
      enhancementLevel: enhancementLevel,
      value: quantity,
      role: role,
    );
  }
}

class TradeMarketTemplateEditorController extends ChangeNotifier {
  static const int maxItemCount = 100;

  final TradeMarketService _tradeMarketService;
  final BDOItemInfoService _itemInfoService;
  final String? templateId;

  final TextEditingController nameController = TextEditingController();
  final List<TemplateEditorItem> items = [];

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

  bool get canSave => nameController.text.trim().isNotEmpty && items.isNotEmpty;

  /// 이름 입력 등 컨트롤러 외부 상태 변화 시 UI(저장 버튼 활성화 등)를 갱신한다.
  void refresh() => notifyListeners();

  Future<void> _init() async {
    if (templateId != null) {
      final template = await _tradeMarketService.getTemplate(templateId!);
      if (template != null) {
        nameController.text = template.name;
        for (final item in template.items) {
          items.add(TemplateEditorItem(
            code: item.code,
            enhancementLevel: item.enhancementLevel,
            role: item.role,
            quantity: item.value,
          ));
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  /// 자동완성 옵션(거래 가능 아이템 목록)을 반환한다.
  List<BDOItemInfo> searchItems(String value, Locale locale) {
    final query = value.replaceAll(" ", "").toLowerCase();
    if (query.isEmpty) {
      return const [];
    }
    return _itemInfoService.tradeAbleItems
        .where((item) => item
            .name(locale)
            .replaceAll(" ", "")
            .toLowerCase()
            .contains(query))
        .toList();
  }

  /// 최대 강화 단계. 강화 불가 아이템은 0.
  int maxEnhancementOf(int code) {
    return _itemInfoService.itemInfo(code.toString()).maxEnhancement;
  }

  /// 자동완성에서 선택한 아이템을 템플릿에 추가한다. 성공 시 true.
  bool addItem(BDOItemInfo itemInfo) {
    if (atCapacity) {
      return false;
    }
    final code = int.tryParse(itemInfo.code);
    if (code == null) {
      return false;
    }
    // 같은 코드/강화 단계 조합의 중복은 막는다. (기본값 0 단계 기준으로 추가)
    if (items.any((item) => item.code == code && item.enhancementLevel == 0)) {
      return false;
    }
    items.add(TemplateEditorItem(
      code: code,
      enhancementLevel: 0,
      role: TradeMarketTemplateItemRole.material,
      quantity: 1,
    ));
    notifyListeners();
    return true;
  }

  void removeItem(TemplateEditorItem item) {
    items.remove(item);
    item.quantityController.dispose();
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
    if (items.any((other) =>
        other != item &&
        other.code == item.code &&
        other.enhancementLevel == level)) {
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
    final template = TradeMarketTemplate(
      id: templateId,
      name: nameController.text.trim(),
      items: items.map((item) => item.toTemplateItem()).toList(),
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
    for (final item in items) {
      item.quantityController.dispose();
    }
    super.dispose();
  }
}
