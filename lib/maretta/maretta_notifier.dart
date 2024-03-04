import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/blacklist_model.dart';
import 'package:karanda/common/channel.dart';
import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/common/http.dart' as http;
import 'package:karanda/maretta/maretta_model.dart';
import 'package:karanda/maretta/maretta_report_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class MarettaNotifier with ChangeNotifier {
  Map<AllChannel, List<MarettaModel>> reportList = HashMap();
  Map<String, BlacklistModel> blacklist = {};
  WebSocketChannel? _channel;
  Timer? _timer;
  DateTime? _lastUpdate;
  bool connected = false;

  MarettaNotifier() {
    initList();
    //connect();
    //getBlacklist();
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

  Future<void> connect() async {
    if (!connected) {
      getReports();
      _channel = WebSocketChannel.connect(Uri.parse(Api.marettaStatusReports));
      await _channel?.ready;
      _channel?.stream.listen(
        (message) {
          if (message != null && message != '') {
            for (Map data in jsonDecode(message)) {
              MarettaReportModel report = MarettaReportModel.fromData(data);
              _addReport(report);
            }
            _lastUpdate = DateTime.now();
            notifyListeners();
          }
        },
        onDone: () {
          if (_channel?.closeCode == status.noStatusReceived) {
            connected = false;
          }
          if (_channel?.closeCode == status.abnormalClosure) {
            _timer?.cancel();
            _timer = null;
            connected = false;
            connect();
          }
        },
        onError: (e) {
          print(
              'error code:${_channel?.closeCode}, reason:${_channel?.closeReason}');
          print(e);
        },
      );
      //_timer ??= Timer.periodic(const Duration(minutes: 1), (timer) => requestUpdate());
      connected = true;
    }
  }

  void requestUpdate() {
    if (_lastUpdate != null &&
        _lastUpdate!
            .isBefore(DateTime.now().subtract(const Duration(minutes: 10)))) {
      _channel?.sink.add('update');
    }
  }

  void disconnect() {
    _channel?.sink.close(status.normalClosure);
    _channel = null;
    _timer?.cancel();
    _timer = null;
    connected = false;
  }

  void initList() {
    for (AllChannel channel in Channel.kr.keys) {
      reportList[channel] = List<MarettaModel>.generate(
        Channel.kr[channel]!,
        (index) => MarettaModel(
          channel: channel,
          channelNumber: index + 1,
        ),
        growable: false,
      );
    }
    notifyListeners();
  }

  Future<bool> createReport(MarettaReportModel item) async {
    final response = await http.post(Api.createMarettaStatusReport,
        body: item.toJson(), json: true);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  void _addReport(MarettaReportModel report) {
    if (!blacklist.keys.contains(report.reporterDiscordId)) {
      MarettaReportModel? old =
          reportList[report.channel]?[report.channelNum - 1].report;
      if (old == null) {
        reportList[report.channel]?[report.channelNum - 1].report = report;
      } else if (report.reportAt.isAfter(old.reportAt)) {
        reportList[report.channel]?[report.channelNum - 1].report = report;
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
        //print(item.userName);
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

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
