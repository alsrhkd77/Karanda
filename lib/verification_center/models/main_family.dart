import 'package:karanda/common/enums/bdo_class.dart';

class MainFamily {
  late String familyName;
  late BdoClass mainClass;
  late String region;
  bool verified = false;

  MainFamily.fromData(Map data){
    familyName = data['familyName'];
    mainClass = BdoClass.values.byName(data['mainClass']);
    region = data['region'];
    verified = data['verified'] ?? false;
  }

  Map toData(){
    Map data = {};
    data['familyName'] = familyName;
    data['mainClass'] = mainClass.name;
    data['region'] = region;
    data['verified'] = verified;
    return data;
  }
}