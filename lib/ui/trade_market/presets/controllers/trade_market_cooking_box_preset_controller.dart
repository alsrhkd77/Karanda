import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_preset_item.dart';
import 'package:karanda/service/trade_market_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TradeMarketCookingBoxPresetController extends ChangeNotifier {
  final TradeMarketService _marketService;
  final BDORegion region;
  final List<Mastery> _mastery = [];
  final contributionsController = TextEditingController(text: "200"); //공헌도
  final proficiencyController = TextEditingController(text: "1200"); //숙련도
  final _contributionsKey = "cooking_box_user_contributions";
  final _proficiencyKey = "cooking_box_user_proficiency";

  int deliveryCounts = 100; //납품 가능 횟수
  Mastery mastery = Mastery(mastery: 1200, silverBonus: 0.9293);
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

  List<TradeMarketPresetItem>? get items => _items[selectedBox]?["materials"];

  int get boxPrice => _items[selectedBox]?["price"] ?? 0;

  bool get isLoaded => !(items?.any((item) => item.price == null) ?? true);

  void selectBox(String value) {
    if (_items.keys.contains(value)) {
      selectedBox = value;
      notifyListeners();
      final materials = _items[value]!["materials"];
      if (materials.any((item) => item.price == null) ?? true) {
        _getPriceData(value);
      }
    }
  }

  Future<void> _getBaseData() async {
    final data = await rootBundle.loadString("assets/data/cooking_box.json");
    final Map json = jsonDecode(data);
    for (String key in json.keys) {
      if (key == "mastery") {
        for (Map item in json[key]) {
          _mastery.add(Mastery.fromJson(item));
        }
      } else {
        final List<TradeMarketPresetItem> materials = [];
        for (Map item in json[key]["materials"]) {
          materials.add(TradeMarketPresetItem.fromJson(item));
        }
        _items[key] = json[key];
        _items[key]!["materials"] = materials;
      }
    }
    selectedBox = _items.keys.last;
    await _loadUserData();
    notifyListeners();
    _getPriceData(_items.keys.last);
  }

  Future<void> _getPriceData(String key) async {
    List<TradeMarketPresetItem> materials = _items[key]?["materials"] ?? [];
    if (materials.isNotEmpty) {
      final prices = await _marketService.getPresetPriceData(materials, region);
      for (TradeMarketPresetItem item in materials) {
        item.price = prices.firstWhere((price) => price.key == item.key);
      }
      materials.sort((a, b) {
        if ((a.price!.currentStock > 0 && b.price!.currentStock > 0) ||
            (a.price!.currentStock == 0 && b.price!.currentStock == 0)) {
          return (a.price!.price * a.value).compareTo(b.price!.price * b.value);
        }
        return b.price!.currentStock.compareTo(a.price!.currentStock);
      });
      _items[key]?["materials"] = materials;
      notifyListeners();
    }
  }

  Future<void> _loadUserData() async {
    final pref = SharedPreferencesAsync();
    final userContributions = await pref.getInt(_contributionsKey);
    final userProficiency = await pref.getInt(_proficiencyKey);
    if (userContributions != null) {
      contributionsController.text = userContributions.toString();
    }
    if (userProficiency != null) {
      proficiencyController.text = userProficiency.toString();
    }
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
    if (text.isNotEmpty && _mastery.isNotEmpty) {
      final value = int.parse(text);
      mastery = _mastery.firstWhere((m) => value >= m.mastery);
      notifyListeners();
      final pref = SharedPreferencesAsync();
      pref.setInt(_proficiencyKey, value);
    }
  }

  @override
  void dispose() {
    contributionsController.removeListener(_onContributionsUpdate);
    proficiencyController.removeListener(_onProficiencyUpdate);
    super.dispose();
  }
}

class Mastery {
  int mastery;
  double silverBonus;

  Mastery({required this.mastery, required this.silverBonus});

  factory Mastery.fromJson(Map json) {
    return Mastery(
      mastery: json["mastery"],
      silverBonus: json["silver bonus"],
    );
  }
}
