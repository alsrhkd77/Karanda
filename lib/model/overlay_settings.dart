import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/enums/recruitment_category.dart';
import 'package:karanda/model/monitor_device.dart';

class OverlaySettings {
  final Set<OverlayFeatures> activatedFeatures = {};
  MonitorDevice monitorDevice;
  bool showWorldBossName;
  final Set<RecruitmentCategory> partyFinderExcludedCategory = {};

  OverlaySettings({
    required this.monitorDevice,
    this.showWorldBossName = false,
    Set<OverlayFeatures>? activatedFeatures,
    Set<RecruitmentCategory>? partyFinderExcludedCategory,
  }) {
    this.activatedFeatures.addAll(activatedFeatures ?? {});
    this
        .partyFinderExcludedCategory
        .addAll(partyFinderExcludedCategory ?? {});
  }

  factory OverlaySettings.fromJson(Map json) {
    final List activated = json["activatedFeatures"] ?? [];
    final List partyFinder = json["partyFinderExcludedCategory"] ?? [];
    return OverlaySettings(
      activatedFeatures: Set.from(activated.map((item) {
        return OverlayFeatures.values.byName(item);
      })),
      monitorDevice: MonitorDevice.fromJson(json["monitorDevice"]),
      showWorldBossName: json["showWorldBossName"] ?? false,
      partyFinderExcludedCategory: Set.from(partyFinder.map((item) {
        return RecruitmentCategory.values.byName(item);
      })),
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
    };
  }
}
