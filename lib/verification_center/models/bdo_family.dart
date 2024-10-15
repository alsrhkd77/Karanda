import 'dart:convert';

import 'package:karanda/common/enums/bdo_class.dart';

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

  BdoFamily.fromJson(String json){
    Map data = jsonDecode(json);
    familyName = data['familyName'];
    mainClass = BdoClass.values.byName(data['mainClass']);
    region = data['region'];
    code = data['code'];
    verified = data['verified'] ?? verified;
    lifeSkillIsPrivate = data['lifeSkillIsPrivate'];
    startVerification = DateTime.tryParse(data['startVerification']);
    firstVerification = DateTime.tryParse(data['firstVerification']);
    secondVerification = DateTime.tryParse(data['secondVerification']);
    lastUpdated = DateTime.tryParse(data['lastUpdated']);
  }
}