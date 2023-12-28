import 'package:karanda/common/channel.dart';
import 'package:karanda/maretta/maretta_report_model.dart';

enum MarettaStatus { alive, unknown, dead }

class MarettaModel {
  late AllChannel channel;
  late int channelNumber;
  MarettaReportModel? report; //가장 최근 제보(2시간 이내, 제와한 제보자의 제보 제외)

  MarettaModel({required this.channel, required this.channelNumber});

  MarettaStatus get status => _getStatus();

  DateTime? get statusAt => _getStatusAt();

  DateTime? _getStatusAt() {
    if (report == null) {
      return null;
    }
    if (!report!.alive &&
        DateTime.now()
            .isAfter(report!.reportAt.add(const Duration(hours: 1)))) {
      return report!.reportAt.add(const Duration(hours: 1));
    }
    return report!.reportAt;
  }

  MarettaStatus _getStatus() {
    if (report != null &&
        DateTime.now()
            .isBefore(report!.reportAt.add(const Duration(hours: 2)))) {
      if (report!.alive &&
          DateTime.now()
              .isAfter(report!.reportAt.add(const Duration(hours: 1)))) {
        return MarettaStatus.unknown;
      } else if (!report!.alive &&
          DateTime.now()
              .isAfter(report!.reportAt.add(const Duration(hours: 1)))) {
        return MarettaStatus.alive;
      }
      return report!.alive ? MarettaStatus.alive : MarettaStatus.dead;
    } else {
      return MarettaStatus.unknown;
    }
  }
}
