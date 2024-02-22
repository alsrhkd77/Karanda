import 'package:karanda/common/channel.dart';
import 'package:karanda/maretta/maretta_report_model.dart';

enum MarettaStatus { alive, unknown, dead }

class MarettaModel {
  late AllChannel channel;
  late int channelNumber;
  MarettaReportModel? report; //가장 최근 제보(2시간 이내, 제와한 제보자의 제보 제외)

  MarettaModel({required this.channel, required this.channelNumber});

  MarettaStatus get status => _getStatus();

  DateTime? get statusAt => report?.reportAt;

  MarettaStatus _getStatus() {
    if (report != null){
      if(report!.alive){
        return MarettaStatus.alive;
      }
      return MarettaStatus.dead;
    }
    return MarettaStatus.unknown;
  }
}
