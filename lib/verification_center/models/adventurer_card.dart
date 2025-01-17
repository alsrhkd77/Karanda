import 'package:karanda/common/enums/adventurer_card_background.dart';
import 'package:karanda/common/enums/bdo_class.dart';
import 'package:karanda/verification_center/models/bdo_family.dart';
import 'package:karanda/verification_center/models/simplified_adventurer_card.dart';

class AdventurerCard extends SimplifiedAdventurerCard {
  AdventurerCardBackground background;
  String familyName;
  String guild;
  String createdOn;
  String contributionPoints;
  String lifeSkillLevel;
  int highestLevel;

  AdventurerCard({
    required super.verificationCode,
    required this.background,
    required super.publishedOn,
    required super.keywords,
    required super.region,
    required this.familyName,
    required super.mainClass,
    required this.guild,
    required this.createdOn,
    required this.contributionPoints,
    required this.lifeSkillLevel,
    required this.highestLevel,
  });

  factory AdventurerCard.fromJson(Map data) {
    return AdventurerCard(
      verificationCode: data['verificationCode'],
      background: AdventurerCardBackground.values.byName(data['background']),
      publishedOn: DateTime.parse(data['publishedOn']),
      keywords: data['keywords'],
      region: data['region'],
      familyName: data['familyName'],
      mainClass: BdoClass.values.byName(data['mainClass']),
      guild: data['guild'],
      createdOn: data['createdOn'],
      contributionPoints: data['contributionPoints'],
      lifeSkillLevel: data['lifeSkillLevel'],
      highestLevel: data['highestLevel'],
    );
  }

  factory AdventurerCard.preview(BdoFamily family) {
    return AdventurerCard(
      verificationCode: "xxxxxx",
      background: AdventurerCardBackground.values.first,
      publishedOn: DateTime.now(),
      keywords: "",
      region: family.region,
      familyName: family.familyName,
      mainClass: family.mainClass,
      guild: family.region == "KR" ? "{소속 길드}" : "{Your guild}",
      createdOn: DateTime.now().toString(),
      contributionPoints: "1234",
      lifeSkillLevel: "",
      highestLevel: 123,
    );
  }
}
