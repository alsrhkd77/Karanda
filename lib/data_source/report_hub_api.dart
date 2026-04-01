import 'dart:convert';

import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/report_hub_settings.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';
import 'package:karanda/utils/http_status.dart';
import 'package:karanda/utils/rest_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportHubApi {
  final String key = "report-hub";

  Future<ReportHubSettings> loadReportHubSettings() async {
    final pref = SharedPreferencesAsync();
    final data = await pref.getString(key);
    if(data != null){
      return ReportHubSettings.fromJson(jsonDecode(data));
    }
    return ReportHubSettings();
  }

  Future<void> saveReportHubSettings(ReportHubSettings value) async {
    final pref = SharedPreferencesAsync();
    await pref.setString(key, jsonEncode(value.toJson()));
  }

  Future<void> getStatus(BDORegion region) async {
    final response = await RestClient.get(KarandaApi.getReportStatus);
    if (response.statusCode == HttpStatus.ok){
      for(Map json in jsonDecode(response.bodyUTF)){
        print(json);
      }
    }
    return null;
  }
}