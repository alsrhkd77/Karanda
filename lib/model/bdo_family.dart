import 'package:karanda/common/enums/bdo_class.dart';
import 'package:karanda/enums/bdo_region.dart';

class BDOFamily {
  String code;
  BDORegion region;
  String familyName;
  BdoClass mainClass;
  bool verified;

  BDOFamily({
    required this.code,
    required this.region,
    required this.familyName,
    required this.mainClass,
    required this.verified,
  });

  factory BDOFamily.fromJson(Map json) {
    return BDOFamily(
      code: json["code"],
      region: BDORegion.values.byName(json["region"]),
      familyName: json["familyName"],
      mainClass: BdoClass.values.byName(json["mainClass"]),
      verified: json["verified"],
    );
  }

  Map toJson(){
    return {
      "code": code,
      "region": region.name,
      "familyName": familyName,
      "mainClass": mainClass.name,
      "verified": verified,
    };
  }
}
