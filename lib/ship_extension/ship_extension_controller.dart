import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../ship_extension/ship_extension_item_model.dart';
import '../ship_extension/ship_extension_model.dart';

class ShipExtensionController extends GetxController {
  List<ShipExtensionModel> ships = [];
  List<ShipExtensionItemModel> items = [];

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

    Map<String, Map<String, dynamic>> shipExtension =
        jsonDecode(shipExtensionJson);
    Map<String, Map<String, dynamic>> shipExtensionItem =
        jsonDecode(shipExtensionItemJson);

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

    items = _items;
    ships = _ships;
    return true;
  }
}
