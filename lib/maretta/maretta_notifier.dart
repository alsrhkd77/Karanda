import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/channel.dart';
import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/maretta/maretta_channel_model.dart';
import 'package:karanda/common/http.dart' as http;
import 'package:karanda/maretta/maretta_report_model.dart';

class MarettaNotifier with ChangeNotifier {
  List<MarettaChannelModel> list = [];

  MarettaNotifier() {
    makeChannelList();
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
    for (MarettaChannelModel channel in list) {
      if (channel.channel == report.channel &&
          !channel.details[report.channelNum - 1].checkContains(report)) {
        channel.details[report.channelNum - 1].report.add(report);
        channel.details[report.channelNum - 1].report.sort();
      }
    }
  }

  Future<void> getBlacklist() async {
    final response = await http.get(Api.getMarettaStatusReport);
  }
}
