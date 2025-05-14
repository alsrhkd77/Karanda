import 'package:karanda/enums/recruitment_join_status.dart';
import 'package:karanda/model/user.dart';

class Applicant {
  final String code;
  final int postId;
  final User user;
  final DateTime joinAt;
  final DateTime? cancelledAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;

  Applicant({
    required this.code,
    required this.postId,
    required this.user,
    required this.joinAt,
    this.cancelledAt,
    this.acceptedAt,
    this.rejectedAt,
  });

  factory Applicant.fromJson(Map json) {
    return Applicant(
      code: json["code"],
      postId: json["postId"],
      user: User.fromJson(json["user"]),
      joinAt: DateTime.parse(json["joinAt"]),
      cancelledAt: DateTime.tryParse(json["cancelledAt"] ?? ""),
      acceptedAt: DateTime.tryParse(json["acceptedAt"] ?? ""),
      rejectedAt: DateTime.tryParse(json["rejectedAt"] ?? ""),
    );
  }

  RecruitmentJoinStatus get status => _status();

  RecruitmentJoinStatus _status() {
    if (rejectedAt != null) {
      return RecruitmentJoinStatus.rejected;
    } else if (cancelledAt != null) {
      return RecruitmentJoinStatus.cancelled;
    } else if (acceptedAt != null) {
      return RecruitmentJoinStatus.accepted;
    }
    return RecruitmentJoinStatus.pending;
  }
}
