import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_material.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_parts.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_ship.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShipUpgradingDataController{
  final _materialDataStreamController = StreamController<Map<String, ShipUpgradingMaterial>>();
  final _selectedShipDataStreamController = StreamController<ShipUpgradingShip>();
  Stream<Map<String, ShipUpgradingMaterial>> get materials => _materialDataStreamController.stream;
  Stream<ShipUpgradingShip> get selectedShip => _selectedShipDataStreamController.stream;

  Map<String, ShipUpgradingShip> _ship = {};
  Map<String, ShipUpgradingParts> _parts = {};

  Map<String, ShipUpgradingShip> get ship => _ship;

  Future<void> updateSelected(String selected) async {
    if(_ship.containsKey(selected)){
      final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('ship_upgrading_selected_ship', selected);
      _selectedShipDataStreamController.sink.add(_ship[selected]!);
    }
  }

  Future<bool> getBaseData() async {
    bool result = false;
    try{
      Map data = jsonDecode(await rootBundle.loadString('assets/data/ship_upgrading.json'));

      _materialDataStreamController.sink.add(_getMaterialData(data['materials']));

      _parts = _getPartsData(data['parts']);

      _ship = _getShipData(data['types']);

      final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

      String? selected = sharedPreferences.getString('ship_upgrading_selected_ship');
      selected = selected ?? _ship.keys.first;
      _selectedShipDataStreamController.sink.add(_ship[selected]!);

      result = true;
    } catch (e) {
      result = false;
    }
    return result;
  }



  Map<String, ShipUpgradingMaterial> _getMaterialData(Map data){
    Map<String, ShipUpgradingMaterial> materialData = {};
    for(String key in data.keys){
      materialData[key] = ShipUpgradingMaterial.fromData(data[key]);
    }
    return materialData;
  }

  Map<String, ShipUpgradingParts> _getPartsData(Map data){
    Map<String, ShipUpgradingParts> partsData = {};
    for(String key in data.keys){
      partsData[key] = ShipUpgradingParts.fromData(data[key]);
    }
    return partsData;
  }

  Map<String, ShipUpgradingShip> _getShipData(Map data){
    Map<String, ShipUpgradingShip> shipData = {};
    for(String key in data.keys){
      shipData[key] = ShipUpgradingShip.fromData(data[key], _parts);
    }
    return shipData;
  }

  void dispose(){
    _materialDataStreamController.close();
  }
}