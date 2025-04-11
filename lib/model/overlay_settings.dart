import 'package:karanda/enums/overlay_features.dart';

class OverlaySettings {
  final Set<OverlayFeatures> activatedFeatures = {};

  OverlaySettings({Set<OverlayFeatures>? activatedFeatures}) {
    this.activatedFeatures.addAll(activatedFeatures ?? {});
  }

  factory OverlaySettings.fromJson(Map json) {
    final List activated = json["activatedFeatures"] ?? [];
    return OverlaySettings(
      activatedFeatures: Set.from(activated.map((item) {
        return OverlayFeatures.values.byName(item);
      })),
    );
  }

  Map<OverlayFeatures, bool> get activationStatus => {
        for (var item in OverlayFeatures.values)
          item: activatedFeatures.contains(item)
      };

  Map toJson() {
    return {
      "activatedFeatures": activatedFeatures.map((item) => item.name).toList(),
    };
  }
}
