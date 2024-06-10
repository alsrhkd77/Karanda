import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:karanda/bdo_news/models/bdo_event_model.dart';
import 'package:karanda/bdo_news/models/bdo_update_model.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/http_response_extension.dart';

class BdoNewsProvider{
  static Future<List<BdoEventModel>> getEvents() async {
    List<BdoEventModel> result = [];
    final response = await http.get(Uri.parse(Api.bdoEvents));
    if(response.statusCode == 200){
      Map data = jsonDecode(response.bodyUTF);
      for(Map d in data.values){
        BdoEventModel event = BdoEventModel.fromData(d);
        if(!event.count.contains('상시')){
          result.add(event);
        }
      }
    }
    return result;
  }

  static Future<List<BdoUpdateModel>> getKRUpdates() async {
    return await _getUpdates(Api.bdoUpdates);
  }

  static Future<List<BdoUpdateModel>> getLabUpdates() async {
    return await _getUpdates(Api.bdoLabUpdates);
  }

  static Future<List<BdoUpdateModel>> _getUpdates(String url) async {
    List<BdoUpdateModel> result = [];
    final response = await http.get(Uri.parse(url));
    if(response.statusCode == 200){
      Map data = jsonDecode(response.bodyUTF);
      for(Map d in data.values){
        BdoUpdateModel update = BdoUpdateModel.fromData(d);
        result.add(update);
      }
    }
    return result;
  }
}