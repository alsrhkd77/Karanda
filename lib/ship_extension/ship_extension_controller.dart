import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../ship_extension/ship_extension_item_model.dart';
import '../ship_extension/ship_extension_model.dart';

class ShipExtensionController extends GetxController {
  RxString select = '에페리아 중범선 : 비상'.obs;
  RxList<ShipExtensionModel> ships = RxList<ShipExtensionModel>();
  RxList<ShipExtensionItemModel> items = RxList<ShipExtensionItemModel>();

  double get percent {
    double need = 0;
    double user = 0;
    for (ShipExtensionItemModel item in extensionItems) {
      int _user = item.user > item.need ? item.need : item.user;
      if (item.reward == 0) {
        need += item.need;
        user += _user;
      } else {
        need += item.need / item.reward;
        user += _user == 0 ? 0 : _user / item.reward;
      }
    }
    return user / need;
  }

  List<ShipExtensionItemModel> get extensionItems {
    List snapshot = items;
    ShipExtensionModel ship = ships.firstWhere((element) => element.name == select.value);
    Map<String, ShipExtensionItemModel> _map = {
      for (ShipExtensionItemModel m in snapshot) m.name: m
    };
    Map<String, int> _model = ship.getNeed();

    for (String m in _model.keys) {
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
      _map[m]!.parts = parts.toList();
      _map[m]!.parts.sort();
      _map[m]!.need = _model[m]!;
    }

    return _map.values.toList();
  }

  Future<void> selectShipType(String value) async {
    select.value = value;
    update();
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('ship_extension_selected', value);
  }

  Future<void> updateUserItem(String name, int count) async {
    items.firstWhere((element) => element.name == name).user = count;
    items.refresh();
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt('ship_extension_user_$name', count);
  }

  Future<bool> getShipData() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String shipExtensionJson = '';
    String shipExtensionItemJson = '';
    List<ShipExtensionModel> _ships = [];
    List<ShipExtensionItemModel> _items = [];
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
      ShipExtensionItemModel _item =
          ShipExtensionItemModel.fromJson(i, shipExtensionItem[i]!);
      int? _user = sharedPreferences.getInt('ship_extension_user_${_item.name}');
      if(_user != null){
        _item.user = _user;
      }
      _items.add(_item);
    }

    for (String s in shipExtension.keys) {
      ShipExtensionModel _ship =
          ShipExtensionModel.fromJson(s, shipExtension[s]!);
      _ships.add(_ship);
    }

    String? _selected = sharedPreferences.getString('ship_extension_selected');
    if(_selected != null){
      select = _selected.obs;
    }

    items = _items.obs;
    ships = _ships.obs;
    return true;
  }
}
