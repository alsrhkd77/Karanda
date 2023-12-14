import 'package:karanda/common/channel.dart';
import 'package:karanda/maretta/maretta_report_model.dart';

enum MarettaStatus { alive, unknown, dead }

class MarettaModel {
  late AllChannel channel;
  late int channelNumber;
  List<MarettaReportModel> report = []; //최근 한시간 제보 내역

  MarettaModel({required this.channel, required this.channelNumber});

  MarettaStatus get status => _getStatus();

  MarettaStatus _getStatus() {
    if (report.isNotEmpty) {
      return report.first.alive ? MarettaStatus.alive : MarettaStatus.dead;
    } else {
      return MarettaStatus.unknown;
    }
  }

  bool checkContains(MarettaReportModel item){
    return report.any((element) => element.reportId == item.reportId);
  }
}
