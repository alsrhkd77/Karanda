import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/service/trade_market_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TradeMarketCookingBoxPresetController extends ChangeNotifier {
  final TradeMarketService _marketService;
  final BDORegion region;
  final contributionsController = TextEditingController(text: "200"); //공헌도
  final proficiencyController = TextEditingController(text: "1200"); //숙련도
  final _contributionsKey = "cooking_box_user_contributions";

  int deliveryCounts = 100; //납품 가능 횟수

  /// 숙련도 구간의 황실 납품 은화 보너스. 표는 생활 숙련도 공용 에셋에서 온다.
  double silverBonus = 0.9293;
  String selectedBox = "9856";
  final Map<String, Map> _items = {
    "9851": {},
    "9852": {},
    "9853": {},
    "9854": {},
    "9855": {},
    "9856": {},
  };

  TradeMarketCookingBoxPresetController({
    required TradeMarketService marketService,
    required this.region,
  }) : _marketService = marketService {
    contributionsController.addListener(_onContributionsUpdate);
    proficiencyController.addListener(_onProficiencyUpdate);
    _getBaseData();
  }

  List<String> get boxKeys => _items.keys.toList();

  List<TradeMarketTemplateItem>? get items => _items[selectedBox]?["materials"];

  int get boxPrice => _items[selectedBox]?["price"] ?? 0;

  bool get isLoaded => !(items?.any((item) => item.unitCost == null) ?? true);

  void selectBox(String value) {
    if (!_items.keys.contains(value)) {
      return;
    }
    selectedBox = value;
    notifyListeners();
    final materials =
        _items[value]?["materials"] as List<TradeMarketTemplateItem>?;
    // 아직 가격을 못 받은 재료가 하나라도 있으면 조회한다.
    if (materials == null || materials.any((item) => item.unitCost == null)) {
      _getPriceData(value);
    }
  }

  Future<void> _getBaseData() async {
    final data = await rootBundle.loadString("assets/data/cooking_box.json");
    final Map json = jsonDecode(data);
    for (String key in json.keys) {
      final List<TradeMarketTemplateItem> materials = [];
      for (Map item in json[key]["materials"]) {
        materials.add(TradeMarketTemplateItem(
          code: item["code"],
          enhancementLevel: item["enhancement level"] ?? 0,
          quantity: item["value"] ?? 1,
        ));
      }
      _items[key] = json[key];
      _items[key]!["materials"] = materials;
    }
    selectedBox = _items.keys.last;
    await _loadUserData();
    notifyListeners();
    _getPriceData(_items.keys.last);
  }

  Future<void> _getPriceData(String key) async {
    List<TradeMarketTemplateItem> materials = _items[key]?["materials"] ?? [];
    if (materials.isEmpty) {
      return;
    }
    // 템플릿과 같은 방식으로 코드를 모아 한 번에 조회한다.
    final keys =
        materials.map((item) => item.key).whereType<String>().toSet().toList();
    final prices = await _marketService.getPriceDataByKeys(keys, region);
    final byKey = {for (final price in prices) price.key: price};
    for (TradeMarketTemplateItem item in materials) {
      item.marketPrice = byKey[item.key];
    }
    // 재고 유무가 같으면 총비용 오름차순, 다르면 재고 있는 쪽이 앞(기존 규칙).
    materials.sort((a, b) {
      final aStock = (a.marketPrice?.currentStock ?? 0) > 0;
      final bStock = (b.marketPrice?.currentStock ?? 0) > 0;
      if (aStock != bStock) {
        return aStock ? -1 : 1;
      }
      return (a.totalCost ?? 0).compareTo(b.totalCost ?? 0);
    });
    _items[key]?["materials"] = materials;
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    final pref = SharedPreferencesAsync();
    final userContributions = await pref.getInt(_contributionsKey);
    if (userContributions != null) {
      contributionsController.text = userContributions.toString();
    }
    // 숙련도는 요리 템플릿과 공용 값을 쓴다. 예전 요리상자 전용 값은 자동으로 이어받는다.
    final mastery =
        await _marketService.getMastery(TradeMarketLifeskill.cooking);
    if (mastery > 0) {
      proficiencyController.text = mastery.toString();
    }
    await _updateSilverBonus(int.tryParse(proficiencyController.text) ?? 0);
  }

  Future<void> _updateSilverBonus(int mastery) async {
    silverBonus = await _marketService.royalTradeSilverBonusOf(
      TradeMarketLifeskill.cooking,
      mastery,
    );
    notifyListeners();
  }

  void _onContributionsUpdate() {
    final text = contributionsController.text;
    if (text.isNotEmpty) {
      final value = int.parse(text);
      deliveryCounts = value ~/ 2;
      notifyListeners();
      final pref = SharedPreferencesAsync();
      pref.setInt(_contributionsKey, value);
    }
  }

  void _onProficiencyUpdate() {
    final text = proficiencyController.text;
    if (text.isEmpty) {
      return;
    }
    final value = int.tryParse(text);
    if (value == null) {
      return;
    }
    // 공용 숙련도라 요리 템플릿의 산출 배율에도 함께 반영된다.
    _marketService.setMastery(TradeMarketLifeskill.cooking, value);
    _updateSilverBonus(value);
  }

  @override
  void dispose() {
    contributionsController.removeListener(_onContributionsUpdate);
    proficiencyController.removeListener(_onProficiencyUpdate);
    super.dispose();
  }
}
