import 'dart:convert';
import 'package:flutter/services.dart';

class LightstoneCombinationDataSource {
  Future<List> getLightstoneData() async {
    final json = jsonDecode(
        await rootBundle.loadString("assets/data/lightstone_combination.json"));
    return json["lightstone"];
  }

  Future<List> getCombinationData() async {
    final json = jsonDecode(
        await rootBundle.loadString("assets/data/lightstone_combination.json"));
    return json["combination"];
  }
}
