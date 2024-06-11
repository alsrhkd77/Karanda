import 'package:karanda/bdo_news/models/bdo_news_model.dart';

class BdoUpdateModel extends BdoNewsModel {
  late String desc;
  late bool major;

  BdoUpdateModel.fromData(Map data) : super.fromData(data) {
    desc = data['desc'];
    major = data.containsKey('major') ? data['major'] : true;
  }

  bool isRecent(){
    Duration diff = DateTime.now().difference(added);
    print(diff.inDays);
    return diff.inDays < 4 ? true : false;
  }
}
