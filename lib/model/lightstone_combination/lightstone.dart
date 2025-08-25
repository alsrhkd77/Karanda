import 'package:flutter/material.dart';
import 'package:karanda/model/lightstone_combination/effect.dart';

class Lightstone {
  final int code;
  final String nameKR;
  final String nameEN;
  final Effect effect;
  final MaterialColor color;

  Lightstone({
    required this.code,
    required this.nameKR,
    required this.nameEN,
    required this.effect,
    required this.color,
  });

  factory Lightstone.fromJson(Map json) {
    final MaterialColor materialColor;
    if (json["name_en"].contains("Fire:")) {
      materialColor = Colors.red;
    } else if (json["name_en"].contains("Wind:")) {
      materialColor = Colors.blue;
    } else if (json["name_en"].contains("Earth:")) {
      materialColor = Colors.orange;
    } else if (json["name_en"].contains("Flora:")) {
      materialColor = Colors.green;
    } else {
      materialColor = Colors.yellow;
    }
    return Lightstone(
      code: json["code"],
      nameKR: json["name_kr"],
      nameEN: json["name_en"],
      effect: Effect.fromJson(json["effect"]),
      color: materialColor,
    );
  }

  bool match(String keyword) {
    if (nameKR.replaceAll(" ", "").contains(keyword)) {
      return true;
    } else if (nameEN.replaceAll(" ", "").toLowerCase().contains(keyword)) {
      return true;
    } else {
      return effect.match(keyword);
    }
  }
}
