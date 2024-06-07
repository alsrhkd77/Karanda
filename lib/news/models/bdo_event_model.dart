import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:karanda/news/models/bdo_news_model.dart';

class BdoEventModel extends BdoNewsModel {
  late DateTime deadline;
  late String count;
  late bool newTag;
  Color color =
      Colors.primaries[Random().nextInt(Colors.primaries.length)].shade100;

  BdoEventModel.fromJson(String json) : super.fromJson(json) {
    Map data = jsonDecode(json);
    deadline = DateTime.parse(data['deadline']);
    count = data['count'];
    newTag = data['new_tag'];
  }
}
