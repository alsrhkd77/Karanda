import 'dart:convert';

import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/model/bdo_family.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';
import 'package:karanda/utils/http_status.dart';
import 'package:karanda/utils/rest_client.dart';

class BDOFamilyApi{
  Future<List<BDOFamily>> getFamilies() async {
    final List<BDOFamily> result = [];
    final response = await RestClient.get(KarandaApi.families);
    if(response.statusCode == HttpStatus.ok){
      for(Map data in jsonDecode(response.bodyUTF)){
        result.add(BDOFamily.fromJson(data));
      }
    }
    return result;
  }
}