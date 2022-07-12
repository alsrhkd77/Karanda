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
    Map<String, ShipExtensionItemModel> _map = {
      for (ShipExtensionItemModel m in snapshot) m.name: m
    };
    Map<String, int> _model =
        ships.firstWhere((element) => element.name == select.value).getNeed();

    for (String m in _model.keys) {
      _map[m]!.need = _model[m]!;
    }

    return _map.values.toList();
  }

  void selectShipType(String value) {
    select.value = value;
    update();
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

    items = _items.obs;
    ships = _ships.obs;
    return true;
  }
}
