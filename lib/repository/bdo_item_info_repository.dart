import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:karanda/data_source/bdo_item_info_data_source.dart';
import 'package:karanda/model/bdo_item_info.dart';

class BDOItemInfoRepository {
  final BDOItemInfoDataSource _dataSource;
  SplayTreeMap<String, BDOItemInfo> _data = SplayTreeMap();

  BDOItemInfoRepository({required BDOItemInfoDataSource dataSource})
      : _dataSource = dataSource;

  List<String> get keys => _data.keys.toList();

  List<BDOItemInfo> get tradeAbleItems =>
      _data.values.where((item) => item.tradeAble).toList();

  /// 거래 불가 아이템을 포함한 전체 목록.
  /// 템플릿에는 거래소에서 살 수 없는 아이템도 들어가므로 검색 대상이 더 넓다.
  List<BDOItemInfo> get items => _data.values.toList();

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
    final SplayTreeMap<String, BDOItemInfo> result = SplayTreeMap();
    final data = await _dataSource.getData();
    for (BDOItemInfo item in data) {
      result[item.code] = item;
    }
    _data = result;
  }
}
