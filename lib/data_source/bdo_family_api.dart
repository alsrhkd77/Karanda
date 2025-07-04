import 'dart:convert';

import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/model/bdo_family.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';
import 'package:karanda/utils/http_status.dart';
import 'package:karanda/utils/rest_client.dart';

import '../enums/bdo_region.dart';

class BDOFamilyApi {
  Future<BDOFamily?> registerFamily({
    required BDORegion region,
    required String code,
    required String familyName,
  }) async {
    final result = await RestClient.post(
      KarandaApi.registerFamily,
      body: jsonEncode({
        "code": code,
        "region": region.name,
        "familyName": familyName,
      }),
      json: true
    );
    if (result.statusCode == HttpStatus.ok) {
      return BDOFamily.fromJson(jsonDecode(result.bodyUTF));
    }
    return null;
  }

  Future<bool> unregisterFamily(BDORegion region, String code) async {
    final result = await RestClient.delete(
      KarandaApi.unregisterFamily,
      body: jsonEncode({
        "code": code,
        "region": region.name,
        "familyName": "",
      }),
      json: true,
    );
    if (result.statusCode == HttpStatus.ok) {
      return true;
    }
    return false;
  }

  Future<Map> startVerification(BDORegion region, String code) async {
    final result = await RestClient.post(
      KarandaApi.startFamilyVerification,
      body: jsonEncode({
        "code": code,
        "region": region.name,
        "familyName": "",
      }),
      json: true,
    );
    if(result.statusCode == HttpStatus.ok){
      return jsonDecode(result.body);
    }
    return {};
  }

  Future<BDOFamily?> verify(BDORegion region, String code) async {
    final result = await RestClient.post(
      KarandaApi.verifyFamily,
      body: jsonEncode({
        "code": code,
        "region": region.name,
        "familyName": "",
      }),
      json: true,
    );
    if (result.statusCode == HttpStatus.ok) {
      return BDOFamily.fromJson(jsonDecode(result.bodyUTF));
    }
    return null;
  }

  Future<BDOFamily?> updateFamilyData(BDORegion region, String code) async {
    final result = await RestClient.post(
      KarandaApi.updateFamilyData,
      body: jsonEncode({
        "code": code,
        "region": region.name,
        "familyName": "",
      }),
      json: true,
    );
    if (result.statusCode == HttpStatus.ok) {
      return BDOFamily.fromJson(jsonDecode(result.bodyUTF));
    }
    return null;
  }
}
