import 'dart:convert';

import 'package:karanda/news/models/bdo_news_model.dart';

class BdoUpdate extends BdoNewsModel {
  late String desc;
  late bool major;

  BdoUpdate.fromJson(String json) : super.fromJson(json) {
    Map data = jsonDecode(json);
    desc = data['desc'];
    major = data.containsKey('major') ? data['major'] : true;
  }
}
