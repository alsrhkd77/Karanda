import 'dart:convert';

import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/model/recruitment.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';
import 'package:karanda/utils/http_status.dart';
import 'package:karanda/utils/rest_client.dart';

class AdventurerHubApi {
  Future<Recruitment?> createPost(RecruitmentPost value) async {
    final response = await RestClient.post(
      KarandaApi.createPost,
      body: jsonEncode(value.toJson()),
    );
    if(response.statusCode == HttpStatus.ok){
      return Recruitment.fromJson(jsonDecode(response.bodyUTF));
    }
    return null;
  }

  Future<Recruitment?> updatePost(Recruitment value) async {
    final response = await RestClient.post(
      KarandaApi.updatePost,
      body: jsonEncode(value.toJson()),
    );
    if(response.statusCode == HttpStatus.ok){
      return Recruitment.fromJson(jsonDecode(response.bodyUTF));
    }
    return null;
  }
}
