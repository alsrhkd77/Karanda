class MarketItemModel {
  late String code;
  late String name;
  late int maxEnhancement;
  late int grade;
  late String mainCategory;
  late String subCategory;

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
}
