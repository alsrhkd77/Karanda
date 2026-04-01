import 'package:karanda/enums/bdo_region.dart';

class ReportStatus {
  final int? id;
  final String target;
  final BDORegion region;
  final String? channel;
  final bool active;
  final DateTime eventAt;
  final DateTime updatedAt;

  ReportStatus({
    this.id,
    required this.target,
    required this.region,
    this.channel,
    required this.active,
    required this.eventAt,
    required this.updatedAt,
  });

  factory ReportStatus.fromJson(Map data) {
    return ReportStatus(
      target: data["target"],
      region: BDORegion.values.byName(data["region"]),
      channel: data["channel"],
      active: data["active"],
      eventAt: DateTime.tryParse(data["eventAt"]) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(data["updatedAt"]) ?? DateTime.now(),
    );
  }
}
