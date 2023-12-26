import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/blacklist_model.dart';
import 'package:karanda/common/channel.dart';
import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/maretta/maretta_channel_model.dart';
import 'package:karanda/common/http.dart' as http;
import 'package:karanda/maretta/maretta_report_model.dart';

class MarettaNotifier with ChangeNotifier {
  List<MarettaChannelModel> list = [];
  Map<String, BlacklistModel> blacklist = {};

  MarettaNotifier() {
    makeChannelList();
    getBlacklist();
    getReports();
  }

  void makeChannelList() {
    for (AllChannel channel in Channel.kr.keys) {
      MarettaChannelModel marettaModel = MarettaChannelModel(
        channel: channel,
        channelNumber: Channel.kr[channel]!,
      );
      list.add(marettaModel);
    }
    notifyListeners();
  }

  Future<void> createReport(MarettaReportModel item) async {
    final response = await http.post(Api.createMarettaStatusReport,
        body: item.toJson(), json: true);
    if (response.statusCode == 200) {
      MarettaReportModel report =
          MarettaReportModel.fromData(jsonDecode(response.bodyUTF));
      _addReport(report);
    }
    notifyListeners();
  }

  Future<void> getReports() async {
    final response = await http
        .get(Api.getMarettaStatusReport)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      for (Map data in jsonDecode(response.bodyUTF)) {
        MarettaReportModel report = MarettaReportModel.fromData(data);
        _addReport(report);
      }
    }
    notifyListeners();
  }

  void _addReport(MarettaReportModel report) {
    if (!blacklist.keys.contains(report.reporterDiscordId)) {
      for (MarettaChannelModel channel in list) {
        if (channel.channel == report.channel) {
          if (channel.details[report.channelNum - 1].report == null ||
              report.reportAt.isAfter(
                  channel.details[report.channelNum - 1].report!.reportAt)) {
            channel.details[report.channelNum - 1].report = report;
          }
        }
      }
    }
  }

  Future<void> getBlacklist() async {
    final response = await http.get(Api.getMarettaBlacklist);
    if (response.statusCode == 200) {
      Map<String, BlacklistModel> items = {};
      for (Map data in jsonDecode(response.bodyUTF)) {
        BlacklistModel item = BlacklistModel.fromData(data);
        items[item.discordId] = item;
        print(item.userName);
      }
      blacklist = items;
      notifyListeners();
    }
  }

  Future<void> createBlacklist(String reporterDiscordId) async {
    Map item = {
      'target_discord_id': reporterDiscordId,
    };
    final response = await http.post(Api.createMarettaBlacklist,
        body: jsonEncode(item), json: true);
    if (response.statusCode == 200) {
      BlacklistModel blocked =
          BlacklistModel.fromData(jsonDecode(response.bodyUTF));
      blacklist[blocked.discordId] = blocked;
      notifyListeners();
    }
  }
}
