import 'package:karanda/common/enums/bdo_class.dart';

class BdoAdventurerProfile {
  String region;
  String familyName;
  BdoClass mainClass;
  String guild;
  String createdOn;
  String contributionPoints;

  BdoAdventurerProfile({
    required this.region,
    required this.familyName,
    required this.mainClass,
    required this.guild,
    required this.createdOn,
    required this.contributionPoints,
  });

  factory BdoAdventurerProfile.fromData(Map data) {
    return BdoAdventurerProfile(
      region: data['region'],
      familyName: data['familyName'],
      mainClass: BdoClass.values.byName(data['mainClass']),
      guild: data['guild'],
      createdOn: data['createdOn'],
      contributionPoints: data['contributionPoints'],
    );
  }
}
