import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_material.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_parts.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_setting.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_ship.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShipUpgradingDataController {
  final _materialDataStreamController =
      StreamController<Map<String, ShipUpgradingMaterial>>.broadcast();
  final _partsDataStreamController =
      StreamController<Map<String, ShipUpgradingParts>>.broadcast();
  final _selectedShipDataStreamController =
      StreamController<ShipUpgradingShip>.broadcast();
  final _totalPercentStreamController = StreamController<double>();
  final _settingStreamController =
      StreamController<ShipUpgradingSetting>.broadcast();

  Stream<Map<String, ShipUpgradingMaterial>> get materials =>
      _materialDataStreamController.stream;

  Stream<Map<String, ShipUpgradingParts>> get parts =>
      _partsDataStreamController.stream;

  Stream<ShipUpgradingShip> get selectedShipData =>
      _selectedShipDataStreamController.stream;

  Stream<double> get totalPercent => _totalPercentStreamController.stream;

  Stream<ShipUpgradingSetting> get setting => _settingStreamController.stream;

  Map<String, ShipUpgradingMaterial> _materials = {};
  Map<String, ShipUpgradingShip> _ship = {};
  Map<String, ShipUpgradingParts> _parts = {};
  String _selectedShip = '';
  final ShipUpgradingSetting _setting = ShipUpgradingSetting();

  Map<String, ShipUpgradingShip> get ship => _ship;

  ShipUpgradingDataController() {
    materials.listen((event) => updateTotalPercent(event.values.toList()));
  }

  Future<void> runDailyQuest() async {
    for (String key in _setting.dailyQuest.keys) {
      int stock = _materials[key]?.userStock ?? 0;
      stock += _setting.dailyQuest[key]!;
      if (stock > 999) stock = 999;
      await updateUserStock(key, stock);
    }
  }

  void updateTotalPercent(List<ShipUpgradingMaterial> dataList) {
    double need = 0;
    double stock = 0;
    for (ShipUpgradingMaterial data in dataList) {
      need += data.neededPoint;
      stock += _setting.changeForm ? data.stockPointWithFinished : data.stockPoint;
    }
    if (need <= 0) {
      _totalPercentStreamController.sink.add(0);
    }
    _totalPercentStreamController.sink.add(stock / need);
  }

  Future<void> updateSelected(String selected) async {
    if (_ship.containsKey(selected)) {
      _selectedShip = selected;
      _selectedShipDataStreamController.sink.add(_ship[_selectedShip]!);
      _initMaterialData(selected);
      final sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('ship_upgrading_selected_ship', selected);
    }
  }

  Future<void> updateUserStock(String code, int value) async {
    if (_materials.containsKey(code)) {
      _materials[code]!.userStock = value;
      String str = value > 0 ? value.toString() : '';
      if (_materials[code]!.controller.text != str) {
        _materials[code]!.controller.text = str;
      }
      _materialDataStreamController.sink.add(_materials);
      final sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setInt('ship_upgrading_material_stock_$code', value);
    }
  }

  Future<void> increaseUserStock(String code) async {
    int stock = _materials[code]?.userStock ?? 0;
    if (stock < 999) {
      stock += 1;
      await updateUserStock(code, stock);
    }
  }

  Future<void> decreaseUserStock(String code) async {
    int stock = _materials[code]?.userStock ?? 0;
    if (stock > 0) {
      stock -= 1;
      await updateUserStock(code, stock);
    }
  }

  Future<void> resetUserStock() async {
    for (String itemCode in _materials.keys) {
      await updateUserStock(itemCode, 0);
    }
  }

  Future<void> setFinished(String key) async {
    if (_parts.containsKey(key)) {
      _parts[key]!.finished = !_parts[key]!.finished;
      _partsDataStreamController.sink.add(_parts);

      //update total stock
      for (String k in _parts[key]!.materials.keys) {
        if (_parts[key]!.finished) {
          _materials[k]!.finished += _parts[key]!.materials[k]!.need;
        } else {
          _materials[k]!.finished -= _parts[key]!.materials[k]!.need;
        }
      }
      _materialDataStreamController.sink.add(_materials);

      final sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setBool(
          'ship_upgrading_finished_parts_$key', _parts[key]!.finished);
    }
  }

  void setCardCloseSetting(bool value) {
    _setting.closeFinishedParts = value;
    _settingStreamController.sink.add(_setting);
  }

  void setShowTableHeaders(bool value) {
    _setting.showTableHeader = value;
    _settingStreamController.sink.add(_setting);
  }

  void setDailyQuest(String code, int value) {
    _setting.updateDailyQuest(code, value);
    _settingStreamController.sink.add(_setting);
  }

  void setShowTotalNeeded(bool value) {
    _setting.showTotalNeeded = value;
    _settingStreamController.sink.add(_setting);
  }

  void setChangeForm() {
    _setting.changeForm = !_setting.changeForm;
    _settingStreamController.sink.add(_setting);
    updateTotalPercent(_materials.values.toList());
  }

  void subscribe() {
    _settingStreamController.sink.add(_setting);
    _materialDataStreamController.sink.add(_materials);
    _partsDataStreamController.sink.add(_parts);
    _selectedShipDataStreamController.sink.add(_ship[_selectedShip]!);
  }

  void _initMaterialData(String selectedShip) {
    for (ShipUpgradingMaterial m in _materials.values) {
      m.finished = 0;
      m.totalNeeded = 0;
      m.totalDays = 0;
    }
    for (String partsKey in _ship[selectedShip]!.parts) {
      for (String key in _parts[partsKey]!.materials.keys) {
        _materials[key]!.totalNeeded += _parts[partsKey]!.materials[key]!.need;
        if (_materials[key]!.obtain.reward > 0) {
          _materials[key]!.totalDays =
              (_materials[key]!.totalNeeded / _materials[key]!.obtain.reward)
                  .ceil();
        }
        if (_parts[partsKey]!.finished) {
          _materials[key]!.finished += _parts[partsKey]!.materials[key]!.need;
        }
      }
    }
    _materialDataStreamController.sink.add(_materials);
  }

  Future<bool> getBaseData() async {
    bool result = false;
    try {
      Map data = jsonDecode(
          await rootBundle.loadString('assets/data/ship_upgrading.json'));

      _materials = await _getMaterialData(data['materials']);
      _materialDataStreamController.sink.add(_materials);

      _parts = await _getPartsData(data['parts']);
      _partsDataStreamController.sink.add(_parts);

      _ship = _getShipData(data['types'], _parts);
      final sharedPreferences = await SharedPreferences.getInstance();

      String? selected =
          sharedPreferences.getString('ship_upgrading_selected_ship');
      _selectedShip = selected ?? _ship.keys.first;
      _selectedShipDataStreamController.sink.add(_ship[_selectedShip]!);

      _initMaterialData(_selectedShip);

      await _setting.load();
      _settingStreamController.sink.add(_setting);

      result = true;
    } catch (e) {
      result = false;
    }
    return result;
  }

  Future<Map<String, ShipUpgradingMaterial>> _getMaterialData(Map data) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    Map<String, ShipUpgradingMaterial> materialData = {};
    for (String key in data.keys) {
      int stock =
          sharedPreferences.getInt('ship_upgrading_material_stock_$key') ?? 0;
      materialData[key] = ShipUpgradingMaterial.fromData(data[key])
        ..userStock = stock
        ..controller.text = stock > 0 ? stock.toString() : '';
    }
    return materialData;
  }

  Future<Map<String, ShipUpgradingParts>> _getPartsData(Map data) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    Map<String, ShipUpgradingParts> partsData = {};
    for (String key in data.keys) {
      bool finished =
          sharedPreferences.getBool('ship_upgrading_finished_parts_$key') ??
              false;
      partsData[key] = ShipUpgradingParts.fromData(data[key])
        ..finished = finished;
      for (String k in partsData[key]!.materials.keys) {
        int days = 0;
        if (_materials[k]!.obtain.reward > 0) {
          days = (partsData[key]!.materials[k]!.need /
                  _materials[k]!.obtain.reward)
              .ceil();
        }
        partsData[key]!.materials[k]!.days = days;
      }
    }
    return partsData;
  }

  Map<String, ShipUpgradingShip> _getShipData(
      Map data, Map<String, ShipUpgradingParts> partsData) {
    Map<String, ShipUpgradingShip> shipData = {};
    for (String key in data.keys) {
      shipData[key] = ShipUpgradingShip.fromData(data[key], partsData);
    }
    return shipData;
  }

  void dispose() {
    _materialDataStreamController.close();
    _partsDataStreamController.close();
    _selectedShipDataStreamController.close();
    _settingStreamController.close();
  }
}
