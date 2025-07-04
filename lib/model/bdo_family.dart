import 'package:karanda/enums/bdo_class.dart';
import 'package:karanda/enums/bdo_region.dart';

class BDOFamily {
  String code;
  BDORegion region;
  String familyName;
  BDOClass mainClass;
  int? maxGearScore;
  bool verified;
  DateTime? lastUpdated;

  BDOFamily({
    required this.code,
    required this.region,
    required this.familyName,
    required this.mainClass,
    required this.maxGearScore,
    required this.verified,
    required this.lastUpdated,
  });

  factory BDOFamily.fromJson(Map json) {
    return BDOFamily(
      code: json["code"],
      region: BDORegion.values.byName(json["region"]),
      familyName: json["familyName"],
      mainClass: BDOClass.values.byName(json["mainClass"]),
      maxGearScore: json["maxGearScore"],
      verified: json["verified"],
      lastUpdated: json["lastUpdated"] != null
          ? DateTime.tryParse(json["lastUpdated"])?.toLocal()
          : null,
    );
  }

  Map toJson() {
    return {
      "code": code,
      "region": region.name,
      "familyName": familyName,
      "mainClass": mainClass.name,
      "maxGearScore": maxGearScore,
      "verified": verified,
      "lastUpdated": lastUpdated.toString()
    };
  }
}
