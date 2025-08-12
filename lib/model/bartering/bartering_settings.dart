import 'package:karanda/model/bartering/bartering_mastery.dart';
import 'package:karanda/model/bartering/ship_profile.dart';

class BarteringSettings {
  bool valuePack;
  BarteringMastery mastery;
  late List<ShipProfile> shipProfiles;
  int lastSelectedShipIndex;

  BarteringSettings({
    this.valuePack = false,
    BarteringMastery? mastery,
    List<ShipProfile>? shipProfiles,
    this.lastSelectedShipIndex = 0,
  }) : mastery = mastery ?? BarteringMastery() {
    if (shipProfiles?.isEmpty ?? true) {
      this.shipProfiles = [ShipProfile()];
    } else {
      this.shipProfiles = shipProfiles!;
      if (lastSelectedShipIndex < 0 ||
          shipProfiles.length <= lastSelectedShipIndex) {
        lastSelectedShipIndex = 0;
      }
    }
  }

  ShipProfile get lastSelectedShip => shipProfiles[lastSelectedShipIndex];

  factory BarteringSettings.fromJson(Map json) {
    final List<ShipProfile> ships = [];
    for (Map data in json["shipProfiles"] ?? []) {
      ships.add(ShipProfile.fromJson(data));
    }
    return BarteringSettings(
      valuePack: json["valuePack"],
      mastery: BarteringMastery.fromJson(json["mastery"]),
      shipProfiles: ships,
      lastSelectedShipIndex: json["lastSelectedShipIndex"],
    );
  }

  Map toJson() {
    return {
      "valuePack": valuePack,
      "mastery": mastery,
      "shipProfiles": shipProfiles.map((profile) => profile.toJson()).toList(),
      "lastSelectedShipIndex": lastSelectedShipIndex,
    };
  }
}
