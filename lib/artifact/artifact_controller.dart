import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ArtifactController extends GetxController {
  final List _combinations = [];
  final List _lightStones = [];
  Set<String> options = {};
  final RxSet<String> _keywords = RxSet();
  RxInt loadItemCount = 10.obs;

  RxList get combinations => _filteredCombinations().obs;
  List<String> get keywords => _keywords.toList();

  void loadMoreItem() {
    if (loadItemCount + 10 >= combinations.length) {
      loadItemCount.value = combinations.length;
    } else {
      loadItemCount += 10;
    }
    update();
  }

  Iterable<String> autoComplete(String txt) {
    return options.where((element) => element.contains(txt));
  }

  void addKeyword(String keyword) {
    _keywords.add(keyword);
    loadItemCount = 10.obs;
    update();
  }

  void removeKeyword(String keyword) {
    _keywords.remove(keyword);
    loadItemCount = 10.obs;
    update();
  }

  Future<bool> getData() async {
    String combinationJson = '';
    String lightStonesJson = '';

    if (kIsWeb) {
      // running on web
      lightStonesJson = await rootBundle.loadString('data/lightStones.json');
      combinationJson = await rootBundle.loadString('data/combination.json');
    } else {
      // running on desktop
      lightStonesJson = await http
          .get(Uri.parse(
              'https://raw.githubusercontent.com/HwanSangYeonHwa/black_event/main/lightStones.json'))
          .then((response) => response.body);
      combinationJson = await http
          .get(Uri.parse(
              'https://raw.githubusercontent.com/HwanSangYeonHwa/black_event/main/combination.json'))
          .then((response) => response.body);
    }

    Map<String, dynamic> lightStonesData = jsonDecode(lightStonesJson);
    Map<String, dynamic> combinationData = jsonDecode(combinationJson);
    _lightStones.clear();
    _combinations.clear();
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
    if (keywords.isEmpty) {
      return _combinations;
    }
    Set result = {};
    result.addAll(_findFromCombinationsName());
    result.addAll(_findFromCombinationsEffect());
    result.addAll(_findFromLightStones());
    return result.toList();
  }

  List _findFromCombinationsName() {
    return _combinations.where((element) {
      for (String value in keywords) {
        if (element['name'].contains(value)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  List _findFromCombinationsEffect() {
    return _combinations.where((element) {
      for (Map effect in element['effect']) {
        for (String value in keywords) {
          if (effect['name'].contains(value)) {
            return true;
          }
        }
      }
      return false;
    }).toList();
  }

  List _findFromLightStones() {
    List stones = _lightStones.where((element) {
      for (String value in keywords) {
        if (element['name'].contains(value) ||
            element['effect']['name'].contains(value)) {
          return true;
        }
      }
      return false;
    }).toList();
    return _combinations.where((element) {
      for (String value in stones.map((e) => e['name'])) {
        if (element['formula'].contains(value)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  List<String> getEffects(String name) {
    List<String> result = [];
    Map data =
        _combinations.firstWhere((element) => element['name'].contains(name));
    Map<String, double> effectValue = {};
    Map<String, String> effectUnit = {};
    for (Map d in data['effect']) {
      effectValue[d['name']] = d['value'].toDouble();
      effectUnit[d['name']] = d['unit'];
    }
    for (String s in data['formula']) {
      if (s.trim() != '-' && s != '오색빛 광명석') {
        Map _stone = _lightStones
            .firstWhere((element) => element['name'].contains(s))['effect'];
        if (effectValue.containsKey(_stone['name'])) {
          effectValue[_stone['name']] =
              (effectValue[_stone['name']]! + _stone['value']!);
        } else {
          effectValue[_stone['name']] = _stone['value'];
          effectUnit[_stone['name']] = _stone['unit'];
        }
      }
    }
    for (String n in effectValue.keys) {
      if (n == '모든 특수 피해량') {
        result.add('$n +${effectValue[n]}${effectUnit[n]}');
      } else if (n.contains('인어의 소망')) {
        result.add(n);
      } else if (effectValue[n]! > 0) {
        result.add('$n +${effectValue[n]!.toInt()}${effectUnit[n]}');
      } else {
        result.add('$n ${effectValue[n]!.toInt()}${effectUnit[n]}');
      }
    }

    return result;
  }
}
