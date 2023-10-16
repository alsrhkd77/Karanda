import 'dart:convert';
import 'package:convert/convert.dart' as converter;

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class TradeMarketNotifier with ChangeNotifier {
  Future<void> getData() async {
    var data = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/HwanSangYeonHwa/black_event/main/hammuu')).then((value) => value.body);
    print(utf8.decode(converter.hex.decode(data)));
  }
}