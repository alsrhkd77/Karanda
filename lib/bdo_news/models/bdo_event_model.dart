import 'dart:math';

import 'package:flutter/material.dart';
import 'package:karanda/bdo_news/models/bdo_news_model.dart';

class BdoEventModel extends BdoNewsModel {
  late DateTime deadline;
  late String count;
  late bool newTag;
  bool nearDeadline = false;
  Color color =
      Colors.primaries[Random().nextInt(Colors.primaries.length)].shade100;

  BdoEventModel.fromData(Map data) : super.fromData(data) {
    deadline = DateTime(2996, 11, 12);
    newTag = data['new_tag'];
    count = data['count'];
    DateTime nowKR = DateTime.now().toUtc().add(const Duration(hours: 9));
    if (!count.contains('상시')) {
      deadline = DateTime.parse(data['deadline']);
      Duration deadlineCount = deadline.difference(deadline.copyWith(
          year: nowKR.year, month: nowKR.month, day: nowKR.day));
      count = '${deadlineCount.inDays} 일 남음';
      if (deadlineCount.inDays <= 3) {
        nearDeadline = true;
      }
    }
  }

  int countToInt() {
    if (count.contains('상시')) {
      return 999;
    } else {
      return int.parse(count.split(' ').first);
    }
  }
}
