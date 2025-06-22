import 'package:karanda/enums/bdo_region.dart';

class UserFcmSettings {
  String token;
  BDORegion region;
  bool partyFinder;

  UserFcmSettings({required this.token, required this.region, this.partyFinder = false,});

  factory UserFcmSettings.fromJson(Map json) {
    return UserFcmSettings(
      token: json["token"],
      region: BDORegion.values.byName(json["region"]),
      partyFinder: json["partyFinder"] ?? false,
    );
  }

  Map toJson() {
    return {
      "token": token,
      "region": region.name,
      "partyFinder": partyFinder,
    };
  }
}
