import 'dart:convert';
import 'package:convert/convert.dart' as converter;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../model/bdo_item_info.dart';
import 'dart:developer' as developer;

class BDOItemInfoDataSource {
  Future<List<BDOItemInfo>> getData() async {
    final List<BDOItemInfo> result = [];
    try {
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
        result.add(item);
      }
    } catch (e) {
      developer.log("Failed to load data\n$e");
    }
    return result;
  }
}