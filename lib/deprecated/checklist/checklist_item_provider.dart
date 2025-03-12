import 'dart:convert';

import 'package:karanda/common/api.dart';
import 'package:karanda/common/date_time_extension.dart';
import 'package:karanda/common/http.dart' as http;
import 'package:karanda/common/http_response_extension.dart';

import 'checklist_finished_item.dart';
import 'checklist_item.dart';

class ChecklistItemProvider{
  Future<Map<Cycle, List<ChecklistItem>>> getChecklistItems() async {
    Map<Cycle, List<ChecklistItem>> checklistItems = {for(Cycle c in Cycle.values) c : []};
    final response = await http.get(Api.getChecklistItems);
    if(response.statusCode == 200){
      List list = jsonDecode(response.bodyUTF);
      for(Map data in list){
        ChecklistItem item = ChecklistItem.fromData(data);
        checklistItems[item.cycle]?.add(item);
      }
      return checklistItems;
    }
    throw Exception('[${response.statusCode}] ${response.body}');
  }

  Future<ChecklistItem> createChecklistItem(ChecklistItem item) async {
    final response = await http.post(Api.createChecklistItem, body: item.toJson(), json: true);
    if(response.statusCode == 200){
      return ChecklistItem.fromJson(response.bodyUTF);
    }else if(response.statusCode == 201){
      throw Exception('같은 제목이 존재합니다');
    }
    throw Exception('[${response.statusCode}] ${response.body}');
  }

  Future<ChecklistFinishedItem> createFinishedItem(String title, DateTime selected) async {
    Map item = {
      "finish_at":selected.toDate().format(null),
      "checklist_item":title
    };
    final response = await http.post(Api.createChecklistFinishedItem, body: jsonEncode(item), json: true);
    if(response.statusCode == 200){
      return ChecklistFinishedItem.fromData(jsonDecode(response.bodyUTF));
    }
    throw Exception('[${response.statusCode}] ${response.body}');
  }

  Future<bool> deleteFinishedItem(int checklistItem, int finishedItem) async {
    Map data = {
      'checklist_item':checklistItem,
      'finished_item':finishedItem,
    };
    final response = await http.delete(Api.deleteChecklistFinishedItem, body: jsonEncode(data), json: true);
    if(response.statusCode == 200){
      if(response.body == 'true'){
        return true;
      }
    }
    return false;
  }

  Future<bool> deleteChecklistItem(int checklistItem) async {
    Map data = {
      'item_id':checklistItem.toString(),
    };
    final response = await http.delete(Api.deleteChecklistItem, body: jsonEncode(data), json: true);
    if(response.statusCode == 200){
      if(response.body == 'true'){
        return true;
      }
    }
    return false;
  }

  Future<ChecklistItem?> updateChecklistItem(ChecklistItem item) async {
    final response = await http.patch(Api.updateChecklistItem, body: item.toJson(), json: true);
    if(response.statusCode == 200){
      return ChecklistItem.fromJson(response.bodyUTF);
    }
    return null;
  }
}