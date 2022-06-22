import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../ship_extension/ship_extension_item_model.dart';
import '../ship_extension/ship_extension_model.dart';

class ShipExtensionController extends GetxController {
  RxString select = '에페리아 중범선 : 비상'.obs;
  RxList<ShipExtensionModel> ships = RxList<ShipExtensionModel>();
  RxList<ShipExtensionItemModel> items = RxList<ShipExtensionItemModel>();

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

  void updateUserItem(String name, int count) {
    items.firstWhere((element) => element.name == name).user = count;
    items.refresh();
  }

  Future<bool> getShipData() async {
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