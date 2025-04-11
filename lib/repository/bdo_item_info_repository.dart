import 'dart:collection';
import 'dart:convert';

import 'package:convert/convert.dart' as converter;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:karanda/model/bdo_item_info.dart';
import 'dart:developer' as developer;

class BDOItemInfoRepository {
  SplayTreeMap<String, BDOItemInfo> _data = SplayTreeMap();

  List<String> get keys => _data.keys.toList();

  List<BDOItemInfo> get tradeAbleItems =>
      _data.values.where((item) => item.tradeAble).toList();

  String getName({required String code, required Locale locale}) {
    return _data[code]?.name(locale) ?? "???";
  }

  BDOItemInfo getItemInfo(String code) {
    if (_data.containsKey(code)) {
      return _data[code]!;
    } else {
      throw Exception("Data not exist\ncode: $code");
    }
  }

  Future<void> getData() async {
    if (_data.isNotEmpty) return;
    try {
      final SplayTreeMap<String, BDOItemInfo> result = SplayTreeMap();
      final data = await rootBundle
          .loadString('assets/Hammuu')
          .then((value) => utf8.decode(converter.hex.decode(value)))
          .then((value) => value.split('\n'));
      String ver = data.first;
      String pattern = ver.characters.last;
      ver = ver.replaceAll(pattern, '');
      data.removeAt(0);
      for (String line in data) {
        final item = BDOItemInfo.fromData(line.split(pattern));
        result[item.code] = item;
      }
      _data = result;
    } catch (e) {
      developer.log("Failed to load data\n$e");
    }
  }
}
