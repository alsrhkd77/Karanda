

class MarketItemModel {
  late String code;
  late String name;
  late int maxEnhancement;
  late int grade;
  late String mainCategory;
  late String subCategory;

  String get category => '$mainCategory > $subCategory';

  MarketItemModel.fromStringData(String data, String splitPattern){
    List<String> parsedData = data.split(splitPattern);
    code = parsedData[0];
    name = parsedData[1];
    maxEnhancement = int.parse(parsedData[2]);
    grade = int.parse(parsedData[3]);
    List<String> category = parsedData[4].split('_');
    mainCategory = category.first;
    subCategory = category.last;
  }

  String nameWithEnhancementLevel(int enhancementLevel){
    if(enhancementLevel == 0){
      return name;
    }
    String level = enhancementLevelToString(enhancementLevel);
    level = convertEnhancementLevel(level);
    return '$level$name';
  }

  String enhancementLevelToString(int enhancementLevel){
    List<String> roman = ['I', 'II', 'III', 'IV', 'V'];
    if(enhancementLevel == 0){
      return '';
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

  static String convertEnhancementLevel(String enhancementLevel){
    switch(enhancementLevel){
      case 'I':
        return '장 : ';
      case 'II':
        return '광 : ';
      case 'III':
        return '고 : ';
      case 'IV':
        return '유 : ';
      case 'V':
        return '동 : ';
      default:
        return enhancementLevel;
    }
  }

}
