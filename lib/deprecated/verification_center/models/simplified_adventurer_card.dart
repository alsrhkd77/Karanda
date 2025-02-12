import 'package:karanda/common/enums/bdo_class.dart';

class SimplifiedAdventurerCard {
  String verificationCode;
  DateTime publishedOn;
  String keywords;
  String region;
  BdoClass mainClass;

  SimplifiedAdventurerCard({
    required this.verificationCode,
    required this.publishedOn,
    required this.keywords,
    required this.region,
    required this.mainClass,
  });

  factory SimplifiedAdventurerCard.fromJson(Map data) {
    return SimplifiedAdventurerCard(
      verificationCode: data['verificationCode'],
      publishedOn: DateTime.parse(data['publishedOn']),
      keywords: data['keywords'],
      region: data['region'],
      mainClass: BdoClass.values.byName(data['mainClass']),
    );
  }
}
