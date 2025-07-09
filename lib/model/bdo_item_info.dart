import 'dart:ui';

import 'package:karanda/utils/api_endpoints/karanda_api.dart';

class BDOItemInfo {
  final String code;
  final String kr;
  final String en;
  final int maxEnhancement;
  final int grade;
  final String mainCategory;
  final String subCategory;
  final bool tradeAble;

  BDOItemInfo({
    required this.code,
    required this.kr,
    required this.en,
    required this.maxEnhancement,
    required this.grade,
    required this.mainCategory,
    required this.subCategory,
    required this.tradeAble,
  });

  factory BDOItemInfo.fromData(List<String> data) {
    return BDOItemInfo(
      code: data[3],
      kr: data[6],
      en: data[7],
      maxEnhancement: int.parse(data[2]),
      grade: int.parse(data[0]),
      mainCategory: data[4],
      subCategory: data[5],
      tradeAble: bool.parse(data[1]),
    );
  }

  String get imagePath => "${KarandaApi.itemImage}/$code.png";

  String name(Locale locale){
    switch(locale.toLanguageTag()){
      case "ko-KR":
        return kr;
      case "en-US":
        return en;
      default:
        return "unknown";
    }
  }

  String enhancementLevelToString(int enhancementLevel){
    List<String> roman = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'];
    if(enhancementLevel == 0){
      return '';
    }
    if(grade == 5){
      return roman[enhancementLevel - 1];
    }
    switch (maxEnhancement){
      case 20:
        if(enhancementLevel <= 15){
          return '+$enhancementLevel ';
        }
        return roman[enhancementLevel - 16];
      case 5:
        return roman[enhancementLevel - 1];
      default:
        return '+$enhancementLevel ';
    }
  }
}
