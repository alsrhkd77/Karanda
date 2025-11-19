import 'dart:ui';

import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/enums/recruitment_category.dart';
import 'package:karanda/model/monitor_device.dart';
import 'package:karanda/ui/core/theme/app_theme.dart';
import 'package:karanda/utils/extension/rect_extension.dart';

class OverlaySettings {
  final Set<OverlayFeatures> activatedFeatures = {};
  MonitorDevice monitorDevice;
  bool showWorldBossName;
  final Set<RecruitmentCategory> partyFinderExcludedCategory = {};
  final Map<OverlayFeatures, int> opacity = {};
  final Map<OverlayFeatures, Rect> position = {};

  OverlaySettings({
    required this.monitorDevice,
    this.showWorldBossName = false,
    Set<OverlayFeatures>? activatedFeatures,
    Set<RecruitmentCategory>? partyFinderExcludedCategory,
    Map<OverlayFeatures, int>? opacity,
    Map<OverlayFeatures, Rect>? position,
  }) {
    this.activatedFeatures.addAll(activatedFeatures ?? {});
    this.partyFinderExcludedCategory.addAll(partyFinderExcludedCategory ?? {});
    this.position.addAll(position ?? {});
    this.opacity.addAll(opacity ?? {});
    for (OverlayFeatures feature in OverlayFeatures.values) {
      if (!this.opacity.containsKey(feature)) {
        this.opacity[feature] = AppTheme.overlayDefaultOpacity;
      }
    }
  }

  factory OverlaySettings.fromJson(Map json) {
    final List activated = json["activatedFeatures"] ?? [];
    final List partyFinder = json["partyFinderExcludedCategory"] ?? [];

    final Map<OverlayFeatures, int> opacity = {};
    if(json.containsKey("opacity")){
      for (String key in json["opacity"].keys) {
        opacity[OverlayFeatures.values.byName(key)] =
        json["opacity"][key];
      }
    }

    final Map<OverlayFeatures, Rect> position = {};
    for (String key in json["position"].keys) {
      position[OverlayFeatures.values.byName(key)] = Rect.fromLTWH(
        json["position"][key]["left"],
        json["position"][key]["top"],
        json["position"][key]["width"],
        json["position"][key]["height"],
      );
    }
    return OverlaySettings(
      activatedFeatures: Set.from(activated.map((item) {
        return OverlayFeatures.values.byName(item);
      })),
      monitorDevice: MonitorDevice.fromJson(json["monitorDevice"]),
      showWorldBossName: json["showWorldBossName"] ?? false,
      partyFinderExcludedCategory: Set.from(partyFinder.map((item) {
        return RecruitmentCategory.values.byName(item);
      })),
      opacity: opacity,
      position: position,
    );
  }

  Map<OverlayFeatures, bool> get activationStatus => {
        for (var item in OverlayFeatures.values)
          item: activatedFeatures.contains(item)
      };

  /*Map<RecruitmentCategory, bool> get partyFinderCategoryStatus => {
    for (var item in RecruitmentCategory.values)
      item: !partyFinderExcludedCategory.contains(item)
  };*/

  Map toJson() {
    return {
      "activatedFeatures": activatedFeatures.map((item) => item.name).toList(),
      "monitorDevice": monitorDevice.toJson(),
      "showWorldBossName": showWorldBossName,
      "partyFinderExcludedCategory":
          partyFinderExcludedCategory.map((item) => item.name).toList(),
      "opacity": opacity.map((key, value) => MapEntry(key.name, value)),
      "position": position.map((key, value) => MapEntry(key.name, value.toJson())),
    };
  }
}
