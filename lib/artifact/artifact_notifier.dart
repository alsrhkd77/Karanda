import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ArtifactNotifier with ChangeNotifier {
  final List _combinations = [];
  final List _lightStones = [];
  Set<String> options = {};
  final Set<String> _keywords = {};
  bool orFilter = true;
  int loadItemCount = 10;

  List<String> get keywords => _keywords.toList();

  List get combinations =>
      orFilter ? _orFilteredCombinations() : _andFilteredCombinations();

  ArtifactNotifier() {
    _getData();
  }

  Iterable<String> autoComplete(String txt) {
    Set<String> result = {txt};
    result.addAll(options.where((element) => element.contains(txt)));
    return result;
  }

  void addKeyword(String keyword) {
    _keywords.add(keyword);
    loadItemCount = 10;
    notifyListeners();
  }

  void removeKeyword(String keyword) {
    _keywords.remove(keyword);
    loadItemCount = 10;
    notifyListeners();
  }

  Future<void> _getData() async {
    String combinationJson = '';
    String lightStonesJson = '';

    lightStonesJson = await http
        .get(Uri.parse(
            'https://raw.githubusercontent.com/HwanSangYeonHwa/Karanda/main/assets/assets/data/lightStones.json'))
        .then((response) => response.body);
    combinationJson = await http
        .get(Uri.parse(
            'https://raw.githubusercontent.com/HwanSangYeonHwa/Karanda/main/assets/assets/data/combination.json'))
        .then((response) => response.body);

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
    notifyListeners();
  }

  void changeFilter() {
    orFilter = !orFilter;
    notifyListeners();
  }

  void loadMoreItem() {
    if (loadItemCount + 10 >= combinations.length) {
      loadItemCount = combinations.length;
    } else {
      loadItemCount += 10;
    }
    notifyListeners();
  }

  List _orFilteredCombinations() {
    if (keywords.isEmpty) {
      return _combinations;
    }
    Set result = {};
    result.addAll(_findFromCombinationsName(_combinations, keywords));
    result.addAll(_findFromCombinationsEffect(_combinations, keywords));
    result.addAll(_findFromLightStones(_combinations, keywords));
    return result.toList();
  }

  List _andFilteredCombinations() {
    if (keywords.isEmpty) {
      return _combinations;
    }
    return _combinations.where((element) {
      for (String value in keywords) {
        if (element['name'].contains(value)) {
          continue;
        }
        if (_findFromCombinationsEffect([element], [value]).isNotEmpty) {
          continue;
        }
        if (_findFromLightStones([element], [value]).isNotEmpty) {
          continue;
        }
        return false;
      }
      return true;
    }).toList();
  }

  List _findFromCombinationsName(List list, List targetKeywords) {
    return list.where((element) {
      for (String value in targetKeywords) {
        if (element['name'].contains(value)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  List _findFromCombinationsEffect(List list, List targetKeywords) {
    return list.where((element) {
      for (Map effect in element['effect']) {
        for (String value in targetKeywords) {
          if (effect['name'].contains(value)) {
            return true;
          }
        }
      }
      return false;
    }).toList();
  }

  List _findFromLightStones(List list, List targetKeywords) {
    List stones = _lightStones.where((element) {
      for (String value in targetKeywords) {
        if (element['name'].contains(value) ||
            element['effect']['name'].contains(value)) {
          return true;
        }
      }
      return false;
    }).toList();
    return list.where((element) {
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
        Map stone = _lightStones
            .firstWhere((element) => element['name'].contains(s))['effect'];
        if (effectValue.containsKey(stone['name'])) {
          effectValue[stone['name']] =
              (effectValue[stone['name']]! + stone['value']!);
        } else {
          effectValue[stone['name']] = stone['value'];
          effectUnit[stone['name']] = stone['unit'];
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
