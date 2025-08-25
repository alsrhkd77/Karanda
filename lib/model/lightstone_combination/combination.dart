import 'dart:ui' show Locale;

import 'package:karanda/model/lightstone_combination/effect.dart';
import 'package:karanda/model/lightstone_combination/lightstone.dart';

class Combination {
  final String nameKR;
  final String nameEN;
  final List<Effect> effects;
  final List<Effect> totalEffects;
  final List<Lightstone> lightstones;
  final bool isAmplified;

  Combination({
    required this.nameKR,
    required this.nameEN,
    required this.effects,
    required this.totalEffects,
    required this.lightstones,
    required this.isAmplified,
  });

  factory Combination.fromJson(Map json, {bool isAmplified = false}) {
    final List<Effect> eff = [];
    final List<Effect> totalEff = [];
    for (Map e in json["effects"]) {
      if(e["name_en"] != "-"){
        eff.add(Effect.fromJson(e));
        totalEff.add(Effect.fromJson(e));
      }
    }
    for (Lightstone stone in json["lightstones"]) {
      if(stone.effect.nameEN == "-"){
        continue;
      }
      final index = totalEff.indexWhere((e) =>
          e.nameEN == stone.effect.nameEN && e.unitEN == stone.effect.unitEN);
      if (index < 0) {
        totalEff.add(stone.effect);
      } else {
        totalEff[index] = totalEff[index] + stone.effect;
      }
    }
    return Combination(
      nameKR: json["name_kr"],
      nameEN: json["name_en"],
      effects: eff,
      totalEffects: totalEff,
      lightstones: List<Lightstone>.from(json["lightstones"]),
      isAmplified: isAmplified,
    );
  }

  String getName(Locale locale) {
    switch (locale.languageCode) {
      case "ko":
        return nameKR;
      default:
        return nameEN;
    }
  }

  bool match(String keyword) {
    if (nameKR.replaceAll(" ", "").contains(keyword)) {
      return true;
    } else if (nameEN.replaceAll(" ", "").toLowerCase().contains(keyword)) {
      return true;
    } else if (totalEffects.any((value) => value.match(keyword))) {
      return true;
    } else if (lightstones.any((stone) => stone.match(keyword))) {
      return true;
    } else {
      return false;
    }
  }
}
