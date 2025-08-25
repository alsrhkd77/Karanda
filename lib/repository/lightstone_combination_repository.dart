import 'package:karanda/data_source/bdo_item_info_data_source.dart';
import 'package:karanda/data_source/lightstone_combination_data_source.dart';
import 'package:karanda/model/lightstone_combination/combination.dart';
import 'package:karanda/model/lightstone_combination/lightstone.dart';

class LightstoneCombinationRepository {
  final LightstoneCombinationDataSource _dataSource;
  final BDOItemInfoDataSource _itemInfoDataSource;

  LightstoneCombinationRepository({
    required LightstoneCombinationDataSource lightstoneCombinationDataSource,
    required BDOItemInfoDataSource itemInfoDataSource,
  })  : _dataSource = lightstoneCombinationDataSource,
        _itemInfoDataSource = itemInfoDataSource;

  Future<List<Combination>> getCombinationData() async {
    final List<Combination> result = [];
    final Map<int, Lightstone> stones = {};
    final items = await _itemInfoDataSource.getData();
    final lightstoneData = await _dataSource.getLightstoneData();
    for (Map json in lightstoneData) {
      final item = items.firstWhere((value) {
        return value.code == json["code"].toString();
      });
      json["name_kr"] = item.kr;
      json["name_en"] = item.en;
      final stone = Lightstone.fromJson(json);
      stones[stone.code] = stone;
    }
    final combinationData = await _dataSource.getCombinationData();
    for (Map json in combinationData) {
      json["lightstones"] =
          json["lightstones"].map((value) => stones[value]).toList();
      result.add(Combination.fromJson(json));
      json["lightstones"] =
          json["amplified"].map((value) => stones[value]).toList();
      result.add(Combination.fromJson(json, isAmplified: true));
    }
    return result;
  }
}
