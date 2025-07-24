import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:karanda/enums/ship_upgrading_data_type.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_child_data.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_data.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_settings.dart';
import 'package:karanda/repository/ship_upgrading_repository.dart';

class ShipUpgradingController extends ChangeNotifier {
  final ShipUpgradingRepository _repository;
  late final StreamSubscription _settings;
  late final StreamSubscription _stock;

  ShipUpgradingSettings settings = ShipUpgradingSettings();
  final Map<int, ShipUpgradingData> ships = {};
  final Map<int, ShipUpgradingData> parts = {};
  final Map<int, ShipUpgradingData> materials = {};
  Map<int, int> stock = {};
  final Map<int, TextEditingController> textController = {
    5807: TextEditingController(),
    5814: TextEditingController(),
    5829: TextEditingController(),
    5832: TextEditingController(),
    5820: TextEditingController(),
    5822: TextEditingController(),
    5824: TextEditingController(),
    5827: TextEditingController(),
    5810: TextEditingController(),
    5828: TextEditingController(),
    5823: TextEditingController(),
    5830: TextEditingController(),
    5812: TextEditingController(),
    5809: TextEditingController(),
    5821: TextEditingController(),
    5815: TextEditingController(),
    5831: TextEditingController(),
  };

  ShipUpgradingController({required ShipUpgradingRepository repository})
      : _repository = repository {
    _settings = _repository.settingsStream.listen(_onSettingsUpdate);
    _stock = _repository.stockStream.listen(_onStockUpdate);
  }

  ShipUpgradingData? get ship => ships[settings.selected];
  List<ShipUpgradingData> selectedParts = [];
  Map<int, ShipUpgradingQuantityData> needs = {};
  Map<int, ShipUpgradingQuantityData> realNeeds = {};

  List<int> get completedParts => selectedParts
      .where((e) => stock[e.code] == 1)
      .map((e) => e.code)
      .toList();

  double get completionRate => ship == null ? 0.0 : calcCompletionRate();

  Future<void> loadData() async {
    final data = await _repository.loadData();
    for (ShipUpgradingData item in data) {
      if (item.type == ShipUpgradingDataType.ship) {
        ships[item.code] = item;
      } else if (item.type == ShipUpgradingDataType.material) {
        materials[item.code] = item;
      } else {
        parts[item.code] = item;
      }
    }
    selectedParts = ship?.materials.map((e) => parts[e.code]!).toList() ?? [];
    calcNeeds();
    calcRealNeeds();
    notifyListeners();
    _repository.loadUserStock();
  }

  void selectShip(ShipUpgradingData? value) {
    if (value != null) {
      settings.selected = value.code;
      _repository.saveSettings(settings);
    }
  }

  Future<void> updateUserStock(int code, int value) async {
    await _repository.saveUserStock(code, value);
  }

  Future<void> increaseUserStock(int code) async {
    if (stock.containsKey(code) && stock[code]! < 9999) {
      final value = stock[code]! + 1;
      await updateUserStock(code, value);
    }
  }

  Future<void> decreaseUserStock(int code) async {
    if (stock.containsKey(code) && stock[code]! > 0) {
      final value = stock[code]! - 1;
      await updateUserStock(code, value);
    }
  }

  Future<void> dailyQuest() async {
    for (ShipUpgradingQuantityData item in settings.dailyQuest) {
      final int value = stock[item.code] ?? 0;
      await updateUserStock(item.code, min(value + item.count, 9999));
    }
  }

  void calcNeeds() {
    Map<int, ShipUpgradingQuantityData> result = {};
    for (ShipUpgradingData item in selectedParts) {
      for (ShipUpgradingQuantityData m in item.materials) {
        if (result.containsKey(m.code)) {
          result[m.code]!.count += m.count;
        } else {
          result[m.code] =
              ShipUpgradingQuantityData(code: m.code, count: m.count);
        }
      }
    }
    needs = result;
  }

  void calcRealNeeds() {
    Map<int, ShipUpgradingQuantityData> result = {};
    for (ShipUpgradingData item in selectedParts) {
      if ((stock[item.code] ?? 0) <= 0) {
        for (ShipUpgradingQuantityData m in item.materials) {
          if (result.containsKey(m.code)) {
            result[m.code]!.count += m.count;
          } else {
            result[m.code] =
                ShipUpgradingQuantityData(code: m.code, count: m.count);
          }
        }
      }
    }
    realNeeds = result;
  }

  double calcCompletionRate() {
    double result = 0.0;
    for (ShipUpgradingQuantityData item in realNeeds.values) {
      final value = min((stock[item.code] ?? 0), item.count);
      result += (value / item.count) / realNeeds.length;
    }
    return result;
  }

  void _onSettingsUpdate(ShipUpgradingSettings value) {
    settings = value;
    if (parts.isNotEmpty) {
      selectedParts = ship?.materials.map((e) => parts[e.code]!).toList() ?? [];
    }
    calcNeeds();
    calcRealNeeds();
    notifyListeners();
  }

  void _onStockUpdate(Map<int, int> value) {
    for (int key in value.keys) {
      String str = value[key]! > 0 ? value[key].toString() : '';
      if (textController[key]?.text != str) {
        textController[key]?.text = str;
      }
    }
    stock = value;
    notifyListeners();
  }

  @override
  void dispose() {
    for (int key in textController.keys) {
      textController[key]?.dispose();
    }
    _settings.cancel();
    _stock.cancel();
    super.dispose();
  }
}
