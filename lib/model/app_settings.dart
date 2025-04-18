import 'package:flutter/material.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/enums/font.dart';

class AppSettings {
  ThemeMode themeMode;
  Font font;
  BDORegion region;
  bool startMinimized;
  bool useTrayMode;
  Size windowSize;
  Offset? windowOffset;

  AppSettings({
    this.themeMode = ThemeMode.dark,
    this.font = Font.notoSansKR,
    this.region = BDORegion.KR,
    this.startMinimized = false,
    this.useTrayMode = false,
    this.windowSize = const Size(1280, 720),
    this.windowOffset,
  });

  factory AppSettings.fromJson(Map json) {
    Offset? offset;
    if (json["windowOffset"]?["dx"] != null &&
        json["windowOffset"]?["dy"] != null) {
      offset = Offset(json["windowOffset"]["dx"], json["windowOffset"]["dy"]);
    }
    return AppSettings(
      themeMode: ThemeMode.values.byName(json["theme-mode"]),
      font: Font.values.byName(json["font"]),
      region: BDORegion.values.byName(json["region"]),
      startMinimized: json["startMinimized"] ?? false,
      useTrayMode: json["useTrayMode"] ?? false,
      windowSize: Size(
        json["windowSize"]?["width"] ?? 1280,
        json["windowSize"]?["height"] ?? 720,
      ),
      windowOffset: offset,
    );
  }

  Map toJson() {
    return {
      "theme-mode": themeMode.name,
      "font": font.name,
      "region": region.name,
      "startMinimized": startMinimized,
      "useTrayMode": useTrayMode,
      "windowSize": {"width": windowSize.width, "height": windowSize.height},
      "windowOffset": {"dx": windowOffset?.dx, "dy": windowOffset?.dy}
    };
  }
}
