import 'dart:convert';

import 'package:karanda/common/date_time_extension.dart';

class ChecklistFinishedItem{
  int? id;
  late DateTime finishAt;
  late int checklistItem;

  ChecklistFinishedItem.fromData(Map data){
    id = data['id'];
    finishAt = DateTime.parse(data['finish_at']);
    checklistItem = data['checklist_item_id'];
  }

  String toJson(){
    Map data = {
      'id': id,
      'finish_at': finishAt.format('yyyy-MM-ddTHH:mm:ss'),
      'checklist_item_id': checklistItem
    };
    return jsonEncode(data);
  }
}