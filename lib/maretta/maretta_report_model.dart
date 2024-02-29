import 'dart:convert';

import 'package:karanda/common/channel.dart';
import 'package:karanda/common/date_time_extension.dart';

class MarettaReportModel implements Comparable<MarettaReportModel> {
  int? reportId;
  String? reporterDiscordId; //제보자 디스코드 id
  late String reporterName; //제보자 닉네임
  late DateTime reportAt;
  late bool alive;
  late AllChannel channel;
  late int channelNum;

  MarettaReportModel(
      {this.reportId,
      required this.reporterName,
      required this.reportAt,
      required this.alive,
      required this.channel,
      required this.channelNum});

  MarettaReportModel.fromData(Map data) {
    reportId = data['id'];
    reporterDiscordId = data['reporter_discord_id'];
    reporterName = data['reporter_name'];
    reportAt = DateTime.parse(data['report_at']);
    alive = data['alive'];
    channel = AllChannel.values.byName(data['channel']);
    channelNum = data['channel_num'];
  }

  MarettaReportModel.fromJson(String json) {
    Map data = jsonDecode(json);
    reportId = data['id'];
    reporterName = data['reporter_name'];
    reportAt = DateTime.parse(data['report_at']);
    alive = data['alive'];
    channel = AllChannel.values.byName(data['channel']);
    channelNum = data['channel_num'];
  }

  String toJson() {
    Map data = {
      'reporter_name': reporterName,
      'report_at': reportAt.format('yyyy-MM-ddTHH:mm:ss'),
      'alive': alive,
      'channel': channel.name,
      'channel_num': channelNum,
    };
    return jsonEncode(data);
  }

  @override
  int compareTo(MarettaReportModel other) {
    return other.reportAt.compareTo(reportAt);
  }
}
