import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:karanda/model/lightstone_combination/combination.dart';
import 'package:karanda/repository/lightstone_combination_repository.dart';

class LightstoneCombinationController extends ChangeNotifier {
  final LightstoneCombinationRepository _repository;

  List<Combination> _combination = [];
  List<Combination> combination = [];
  Set<String> autocompleteOptionsKR = {};
  Set<String> autocompleteOptionsEN = {};
  Set<String> keywords = {};

  bool viewAmplified = true;
  bool useAndFilter = false;

  LightstoneCombinationController({
    required LightstoneCombinationRepository repository,
  }) : _repository = repository;

  Future<void> getData() async {
    _combination = await _repository.getCombinationData();
    for (Combination data in _combination) {
      if (data.isAmplified) {
        continue;
      }
      data.lightstones.sort((a, b) => a.code.compareTo(b.code));
      autocompleteOptionsKR.add(data.nameKR);
      autocompleteOptionsKR.addAll(data.effects.map((effect) => effect.nameKR));
      autocompleteOptionsKR
          .addAll(data.lightstones.map((stone) => stone.nameKR));
      autocompleteOptionsKR
          .addAll(data.lightstones.map((stone) => stone.effect.nameKR));
      autocompleteOptionsEN.add(data.nameEN);
      autocompleteOptionsEN.addAll(data.effects.map((effect) => effect.nameEN));
      autocompleteOptionsEN
          .addAll(data.lightstones.map((stone) => stone.nameEN));
      autocompleteOptionsEN
          .addAll(data.lightstones.map((stone) => stone.effect.nameEN));
    }
    _filterCombination();
  }

  Iterable<String> buildOptions(String keyword, Locale locale) {
    final List<String> result = [keyword];
    switch (locale.languageCode) {
      case "ko":
        result.addAll(autocompleteOptionsKR.where((value) {
          return value
              .replaceAll(" ", "")
              .contains(keyword.replaceAll(" ", ""));
        }));
      default:
        result.addAll(autocompleteOptionsEN.where((value) {
          return value
              .replaceAll(" ", "")
              .toLowerCase()
              .contains(keyword.replaceAll(" ", "").toLowerCase());
        }));
    }
    return result;
  }

  void addKeyword(String value) {
    if (value.isNotEmpty) {
      keywords.add(value);
      _filterCombination();
    }
  }

  void removeKeyword(String value) {
    keywords.remove(value);
    _filterCombination();
  }

  void setViewAmplified(bool? value) {
    if (value != null) {
      viewAmplified = value;
      _filterCombination();
    }
  }

  void setAndFilter(bool value) {
    useAndFilter = value;
    _filterCombination();
  }

  void _filterCombination() {
    if (viewAmplified) {
      combination = _combination.where((value) => value.isAmplified).toList();
    } else {
      combination = _combination.where((value) => !value.isAmplified).toList();
    }
    if (keywords.isNotEmpty) {
      if (useAndFilter) {
        for (String keyword in keywords) {
          keyword = keyword.replaceAll(" ", "").toLowerCase();
          combination = combination.where((value) {
            return value.match(keyword);
          }).toList();
        }
      } else {
        final Set<Combination> result = {};
        for (String keyword in keywords) {
          keyword = keyword.replaceAll(" ", "").toLowerCase();
          result.addAll(combination.where((value) {
            return value.match(keyword);
          }));
        }
        combination = result.toList();
      }
    }
    notifyListeners();
  }
}
