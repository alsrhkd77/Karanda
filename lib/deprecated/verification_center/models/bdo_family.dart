import 'package:karanda/common/enums/bdo_class.dart';
import 'package:karanda/deprecated/verification_center/models/simplified_adventurer_card.dart';

class BdoFamily {
  late String familyName;
  late BdoClass mainClass;
  late String region;
  late String code;
  bool verified = false;
  late bool lifeSkillIsPrivate;
  DateTime? startVerification;
  DateTime? firstVerification;
  DateTime? secondVerification;
  DateTime? lastUpdated;
  List<SimplifiedAdventurerCard> adventurerCards = [];

  bool get refreshable =>
      lastUpdated != null &&
      lastUpdated!
          .isAfter(DateTime.now().add(const Duration(minutes: 10)).toUtc());

  BdoFamily.fromData(Map data) {
    familyName = data['familyName'];
    mainClass = BdoClass.values.byName(data['mainClass']);
    region = data['region'];
    code = data['code'];
    verified = data['verified'] ?? verified;
    lifeSkillIsPrivate = data['lifeSkillIsPrivate'];
    startVerification = DateTime.tryParse(data['startVerification'] ?? "");
    firstVerification = DateTime.tryParse(data['firstVerification'] ?? "");
    secondVerification = DateTime.tryParse(data['secondVerification'] ?? "");
    lastUpdated = DateTime.tryParse(data['lastUpdated'] ?? "");
    for(Map items in data['adventurerCards']){
      adventurerCards.add(SimplifiedAdventurerCard.fromJson(items));
    }
  }

  void removeAdventurerCard(String code){
    adventurerCards.removeWhere((card)=> card.verificationCode == code);
  }

  bool isSame(BdoFamily other){
    if(code == other.code && region == other.region) return true;
    return false;
  }
}
