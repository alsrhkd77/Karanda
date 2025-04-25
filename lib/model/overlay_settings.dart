import 'package:karanda/enums/overlay_features.dart';
import 'package:karanda/model/monitor_device.dart';

class OverlaySettings {
  final Set<OverlayFeatures> activatedFeatures = {};
  MonitorDevice monitorDevice;

  OverlaySettings({required this.monitorDevice, Set<OverlayFeatures>? activatedFeatures}) {
    this.activatedFeatures.addAll(activatedFeatures ?? {});
  }

  factory OverlaySettings.fromJson(Map json) {
    final List activated = json["activatedFeatures"] ?? [];
    return OverlaySettings(
      activatedFeatures: Set.from(activated.map((item) {
        return OverlayFeatures.values.byName(item);
      })),
      monitorDevice: MonitorDevice.fromJson(json["monitorDevice"])
    );
  }

  Map<OverlayFeatures, bool> get activationStatus => {
        for (var item in OverlayFeatures.values)
          item: activatedFeatures.contains(item)
      };

  Map toJson() {
    return {
      "activatedFeatures": activatedFeatures.map((item) => item.name).toList(),
      "monitorDevice": monitorDevice.toJson(),
    };
  }
}
