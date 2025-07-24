import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_child_data.dart';
import 'package:karanda/repository/ship_upgrading_repository.dart';

import '../../../enums/ship_upgrading_data_type.dart';
import '../../../model/ship_upgrading/ship_upgrading_data.dart';
import '../../../model/ship_upgrading/ship_upgrading_settings.dart';

class ShipUpgradingSettingsController extends ChangeNotifier {
  final ShipUpgradingRepository _repository;
  late StreamSubscription _settings;
  late StreamSubscription _stock;

  ShipUpgradingSettings? settings = ShipUpgradingSettings();
  final Map<int, ShipUpgradingData> ships = {};
  final Map<int, ShipUpgradingData> _parts = {};
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

  ShipUpgradingSettingsController({required ShipUpgradingRepository repository})
      : _repository = repository {
    _settings = _repository.settingsStream.listen(_onSettingsUpdate);
    _stock = _repository.stockStream.listen(_onStockUpdate);
  }

  List<ShipUpgradingData> get parts =>
      ships[settings?.selected]
          ?.materials
          .map((item) => _parts[item.code]!)
          .where((item) => item.type != ShipUpgradingDataType.license)
          .toList() ??
      [];

  Future<void> loadData() async {
    final data = await _repository.loadData();
    for (ShipUpgradingData item in data) {
      if (item.type == ShipUpgradingDataType.ship) {
        ships[item.code] = item;
      } else if (item.type == ShipUpgradingDataType.material) {
        continue;
      } else {
        _parts[item.code] = item;
      }
    }
    notifyListeners();
    _repository.loadUserStock();
  }

  Future<void> resetUserStock() async {
    await _repository.resetUserStock();
  }

  void selectParts(int code) {
    if (stock.containsKey(code)) {
      _repository.saveUserStock(code, stock[code] == 0 ? 1 : 0);
    }
  }

  void updateDailyQuest(int code, int value) {
    if (settings != null) {
      final index =
          settings!.dailyQuest.indexWhere((item) => item.code == code);
      if (index >= 0) {
        settings?.dailyQuest[index].count = value;
        _repository.saveSettings(settings!);
      }
    }
  }

  void _onSettingsUpdate(ShipUpgradingSettings value) {
    for (ShipUpgradingQuantityData item in value.dailyQuest) {
      String str = item.count > 0 ? item.count.toString() : '';
      textController[item.code]?.text = str;
    }
    settings = value;
    notifyListeners();
  }

  void _onStockUpdate(Map<int, int> value) {
    stock = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _settings.cancel();
    _stock.cancel();
    super.dispose();
  }
}
