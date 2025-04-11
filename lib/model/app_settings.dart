import 'package:flutter/material.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/enums/font.dart';

class AppSettings {
  ThemeMode themeMode;
  Font font;
  BDORegion region;

  AppSettings({
    this.themeMode = ThemeMode.dark,
    this.font = Font.notoSansKR,
    this.region = BDORegion.KR,
  });

  factory AppSettings.fromJson(Map json) {
    return AppSettings(
      themeMode: ThemeMode.values.byName(json["theme-mode"]),
      font: Font.values.byName(json["font"]),
      region: BDORegion.values.byName(json["region"]),
    );
  }

  Map toJson() {
    return {
      "theme-mode": themeMode.name,
      "font": font.name,
      "region": region.name,
    };
  }
}
