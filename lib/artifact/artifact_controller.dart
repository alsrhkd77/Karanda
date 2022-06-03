import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ArtifactController extends GetxController {
  final List _combinations = [];
  final List _lightStones = [];
  Set<String> options = {};
  final RxSet<String> _keywords = RxSet();

  List get combinations => _filteredCombinations();

  List<String> get keywords => _keywords.toList();

  Iterable<String> autoComplete(String txt) {
    return options.where((element) => element.contains(txt));
  }

  void addKeyword(String keyword) {
    _keywords.add(keyword);
    update();
  }

  void removeKeyword(String keyword){
    _keywords.remove(keyword);
    update();
  }

  Future<bool> getData() async {
    var lightStonesJson = await rootBundle.loadString('data/lightStones.json');
    var combinationJson = await rootBundle.loadString('data/combination.json');
    Map<String, dynamic> lightStonesData = jsonDecode(lightStonesJson);
    Map<String, dynamic> combinationData = jsonDecode(combinationJson);
    _lightStones.addAll(lightStonesData['light_stones']);
    _combinations.addAll(combinationData['combat']);
    _combinations.addAll(combinationData['life']);

    options.addAll(_lightStones.map((e) => e['effect']['name']));
    options.addAll(_lightStones.map((e) => e['name']));
    options.addAll(_combinations.map((e) => e['name']));
    for (List eff in _combinations.map((e) => e['effect'])) {
      for (var element in eff) {
        options.add(element['name']);
      }
    }
    return true;
  }

  List _filteredCombinations() {
    Set result = {};

    return result.toList();
  }
}
