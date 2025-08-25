import 'dart:ui' show Locale;

class Effect {
  final String nameKR;
  final String nameEN;
  final String unitKR;
  final String unitEN;
  final double value;

  Effect({
    required this.nameKR,
    required this.nameEN,
    required this.unitKR,
    required this.unitEN,
    required this.value,
  });

  factory Effect.fromJson(Map json) {
    return Effect(
      nameKR: json["name_kr"],
      nameEN: json["name_en"],
      unitKR: json["unit_kr"],
      unitEN: json["unit_en"],
      value: json["value"],
    );
  }

  Effect operator +(Effect other) {
    if (nameKR != other.nameKR ||
        nameEN != other.nameEN ||
        unitKR != other.unitKR ||
        unitEN != other.unitEN) {
      throw Exception(
          "Effect is different!\nCurrent: $nameEN\nOther: ${other.nameEN}");
    }
    return Effect(
      nameKR: nameKR,
      nameEN: nameEN,
      unitKR: unitKR,
      unitEN: unitEN,
      value: value + other.value,
    );
  }

  bool match(String keyword) {
    if (nameKR.replaceAll(" ", "").contains(keyword)) {
      return true;
    } else if (nameEN.replaceAll(" ", "").toLowerCase().contains(keyword)) {
      return true;
    } else if (unitKR.replaceAll(" ", "").contains(keyword)) {
      return true;
    } else if (unitEN.replaceAll(" ", "").toLowerCase().contains(keyword)) {
      return true;
    } else {
      return false;
    }
  }

  String getText(Locale locale) {
    if (nameEN == "-") return "";
    final sign = value > 0 ? "+" : "";
    String signedValue = "$sign$value";
    if (value == 0) {
      signedValue = "";
    } else if (value == value.toInt()) {
      signedValue = "$sign${value.toInt()}";
    }
    switch (locale.languageCode) {
      case "ko":
        return "$nameKR $signedValue$unitKR";
      default:
        return "$nameEN $signedValue$unitEN";
    }
  }
}
