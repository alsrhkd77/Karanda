import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:karanda/ship_extension/ship_extension_item_model.dart';
import 'package:karanda/ship_extension/ship_extension_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShipExtensionNotifier with ChangeNotifier {
  String select = "에페리아 중범선 : 비상";
  List<ShipExtensionModel> ships = [];
  List<ShipExtensionItemModel> items = [];
  List<String> finished = [];


  ShipExtensionNotifier(){
    getShipData();
  }

  double get percent {
    double need = 0;
    double user = 0;
    for (ShipExtensionItemModel item in extensionItems) {
      int userAmount = item.user > item.need ? item.need : item.user;
      if (item.reward == 0) {
        need += item.need;
        user += userAmount;
      } else {
        need += item.need / item.reward;
        user += userAmount == 0 ? 0 : userAmount / item.reward;
      }
    }
    return user / need;
  }

  List<ShipExtensionItemModel> get extensionItems {
    List snapshot = items;
    ShipExtensionModel ship = ships.firstWhere((element) => element.name == select);
    Map<String, ShipExtensionItemModel> data = {
      for (ShipExtensionItemModel m in snapshot) m.name: m
    };
    Map<String, int> model = ship.getNeed();

    for (String m in model.keys) {
      Set<String> parts = {};
      if(ship.prowItem.containsKey(m)){
        parts.add('prow');
      }
      if(ship.cannonItem.containsKey(m)){
        parts.add('cannon');
      }
      if(ship.platingItem.containsKey(m)){
        parts.add('plating');
      }
      if(ship.windSailItem.containsKey(m)){
        parts.add('windSail');
      }
      data[m]!.parts = parts.toList();
      data[m]!.parts.sort();
      data
      [m]!.need = model[m]!;
    }

    return data.values.toList();
  }

  Future<void> selectShipType(String value) async {
    select = value;
    notifyListeners();
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('ship_extension_selected', value);
  }

  Future<void> updateUserItem(String name, int count) async {
    items.firstWhere((element) => element.name == name).user = count;
    notifyListeners();
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt('ship_extension_user_$name', count);
  }

  Future<void> getShipData() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String shipExtensionJson = '';
    String shipExtensionItemJson = '';
    List<ShipExtensionModel> shipData = [];
    List<ShipExtensionItemModel> itemData = [];
    shipExtensionJson = await http
        .get(Uri.parse(
        'https://raw.githubusercontent.com/HwanSangYeonHwa/Karanda/main/assets/assets/data/shipExtension.json'))
        .then((response) => response.body);
    shipExtensionItemJson = await http
        .get(Uri.parse(
        'https://raw.githubusercontent.com/HwanSangYeonHwa/Karanda/main/assets/assets/data/shipExtensionItem.json'))
        .then((response) => response.body);

    Map<String, dynamic> shipExtension = jsonDecode(shipExtensionJson);
    Map<String, dynamic> shipExtensionItem = jsonDecode(shipExtensionItemJson);

    for (String i in shipExtensionItem.keys) {
      ShipExtensionItemModel item =
      ShipExtensionItemModel.fromJson(i, shipExtensionItem[i]!);
      int? user = sharedPreferences.getInt('ship_extension_user_${item.name}');
      if(user != null){
        item.user = user;
      }
      itemData.add(item);
    }

    for (String s in shipExtension.keys) {
      ShipExtensionModel ship =
      ShipExtensionModel.fromJson(s, shipExtension[s]!);
      shipData.add(ship);
    }

    String? selected = sharedPreferences.getString('ship_extension_selected');
    if(selected != null){
      select = selected;
    }

    List<String>? finishedItems = sharedPreferences.getStringList('ship_extension_f');
    if(finishedItems != null){
      finished = finishedItems;
    }

    items = itemData;
    ships = shipData;
    notifyListeners();
  }

  Future<void> updateFinished(String partsName) async {
    if(!finished.remove(partsName)){
      finished.add(partsName);
    }
    notifyListeners();
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setStringList('ship_extension_f', finished);
  }
}