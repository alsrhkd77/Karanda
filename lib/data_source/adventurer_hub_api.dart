import 'dart:convert';

import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/adventurer_hub_settings.dart';
import 'package:karanda/model/applicant.dart';
import 'package:karanda/model/recruitment.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';
import 'package:karanda/utils/http_status.dart';
import 'package:karanda/utils/rest_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdventurerHubApi {
  final String key = "adventurer hub";

  Future<AdventurerHubSettings> loadAdventurerHubSettings() async {
    final pref = SharedPreferencesAsync();
    final data = await pref.getString(key);
    if (data != null) {
      return AdventurerHubSettings.fromJson(jsonDecode(data));
    }
    return AdventurerHubSettings();
  }

  Future<void> saveAdventurerHubSettings(AdventurerHubSettings value) async {
    final pref = SharedPreferencesAsync();
    await pref.setString(key, jsonEncode(value.toJson()));
  }

  Future<Recruitment?> createPost(RecruitmentPost value) async {
    final response = await RestClient.post(
      KarandaApi.createPost,
      body: jsonEncode(value.toJson()),
      json: true,
    );
    if (response.statusCode == HttpStatus.created) {
      return Recruitment.fromJson(jsonDecode(response.bodyUTF));
    }
    return null;
  }

  Future<Recruitment?> updatePost(Recruitment value) async {
    final response = await RestClient.patch(
      KarandaApi.updatePost,
      body: jsonEncode(value.toJson()),
      json: true,
    );
    if (response.statusCode == HttpStatus.ok) {
      return Recruitment.fromJson(jsonDecode(response.bodyUTF));
    }
    return null;
  }

  Future<List<Recruitment>> getPosts(BDORegion region) async {
    final List<Recruitment> result = [];
    final response = await RestClient.get(
      KarandaApi.getRecentPosts,
      parameters: {
        "region": region.name,
      },
    );
    if (response.statusCode == HttpStatus.ok) {
      for (Map json in jsonDecode(response.bodyUTF)) {
        result.add(Recruitment.fromJson(json));
      }
    }
    return result;
  }

  Future<Recruitment?> getPost(int postId) async {
    final response = await RestClient.get(
      KarandaApi.getPost,
      parameters: {"postId": postId.toString()},
    );
    if (response.statusCode == HttpStatus.ok) {
      return Recruitment.fromJson(jsonDecode(response.bodyUTF));
    }
    return null;
  }

  Future<Recruitment?> getPostDetail(int postId) async {
    final response = await RestClient.get(
      KarandaApi.getPostDetail,
      parameters: {"postId": postId.toString()},
    );
    if (response.statusCode == HttpStatus.ok) {
      return Recruitment.fromJson(jsonDecode(response.bodyUTF));
    }
    return null;
  }

  Future<Applicant?> getApplicant(int postId) async {
    final response = await RestClient.get(
      KarandaApi.getApplicant,
      parameters: {"postId": postId.toString()},
    );
    if (response.statusCode == HttpStatus.ok) {
      return Applicant.fromJson(jsonDecode(response.bodyUTF));
    }
    return null;
  }

  Future<List<Applicant>> getApplicants(int postId) async {
    final List<Applicant> result = [];
    final response = await RestClient.get(
      KarandaApi.getApplicants,
      parameters: {"postId": postId.toString()},
    );
    if (response.statusCode == HttpStatus.ok) {
      for (Map json in jsonDecode(response.bodyUTF)) {
        result.add(Applicant.fromJson(json));
      }
    }
    return result;
  }

  Future<List<Applicant>> getUserJoined() async {
    final List<Applicant> result = [];
    final response = await RestClient.get(KarandaApi.getUserJoined);
    if (response.statusCode == HttpStatus.ok) {
      for (Map json in jsonDecode(response.bodyUTF)) {
        result.add(Applicant.fromJson(json));
      }
    }
    return result;
  }

  Future<Recruitment?> openPost(int postId) async {
    final response = await RestClient.post(
      KarandaApi.openPost,
      body: {"postId": postId.toString()},
    );
    if (response.statusCode == HttpStatus.ok) {
      return Recruitment.fromJson(jsonDecode(response.bodyUTF));
    }
    return null;
  }

  Future<Recruitment?> closePost(int postId) async {
    final response = await RestClient.post(
      KarandaApi.closePost,
      body: {"postId": postId.toString()},
    );
    if (response.statusCode == HttpStatus.ok) {
      return Recruitment.fromJson(jsonDecode(response.bodyUTF));
    }
    return null;
  }

  Future<Applicant?> join(int postId) async {
    final response = await RestClient.post(
      KarandaApi.joinToPost,
      body: {"postId": postId.toString()},
    );
    if (response.statusCode == HttpStatus.ok) {
      return Applicant.fromJson(jsonDecode(response.bodyUTF));
    }
    return null;
  }

  Future<Applicant?> cancel(int postId) async {
    final response = await RestClient.post(
      KarandaApi.cancelToPost,
      body: {"postId": postId.toString()},
    );
    if (response.statusCode == HttpStatus.ok) {
      return Applicant.fromJson(jsonDecode(response.bodyUTF));
    }
    return null;
  }

  Future<Applicant?> accept(int postId, String applicantId) async {
    final response = await RestClient.post(
      KarandaApi.cancelToPost,
      body: {"postId": postId.toString(), "applicantId": applicantId},
    );
    if (response.statusCode == HttpStatus.ok) {
      return Applicant.fromJson(jsonDecode(response.bodyUTF));
    }
    return null;
  }

  Future<Applicant?> reject(int postId, String applicantId) async {
    final response = await RestClient.post(
      KarandaApi.cancelToPost,
      body: {"postId": postId.toString(), "applicantId": applicantId},
    );
    if (response.statusCode == HttpStatus.ok) {
      return Applicant.fromJson(jsonDecode(response.bodyUTF));
    }
    return null;
  }
}
