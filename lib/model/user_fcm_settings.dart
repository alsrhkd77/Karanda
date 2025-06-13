import 'package:karanda/enums/bdo_region.dart';

class UserFcmSettings {
  String token;
  BDORegion region;
  bool adventurerHub;

  UserFcmSettings({required this.token, required this.region, this.adventurerHub = false,});

  factory UserFcmSettings.fromJson(Map json) {
    return UserFcmSettings(
      token: json["token"],
      region: BDORegion.values.byName(json["region"]),
      adventurerHub: json["adventurerHub"] ?? false,
    );
  }

  Map toJson() {
    return {
      "token": token,
      "region": region.name,
      "adventurerHub": adventurerHub,
    };
  }
}
