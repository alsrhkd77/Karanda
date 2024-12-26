import 'package:karanda/auth/user.dart';
import 'package:karanda/common/enums/applicant_status.dart';

class Applicant {
  String? code;
  String? reason;
  late int postId;
  late User user;
  late DateTime appliedAt;
  DateTime? canceledAt;
  DateTime? approvedAt;
  DateTime? rejectedAt;

  ApplicantStatus get status => _getStatus();

  Applicant.fromData(Map data){
    code = data['code'];
    reason = data['reason'];
    postId = data['postId'];
    user = User.fromData(data['user']);
    appliedAt = DateTime.parse(data['appliedAt']);
    canceledAt = DateTime.tryParse(data['canceledAt'] ?? "");
    approvedAt = DateTime.tryParse(data['approvedAt'] ?? "");
    rejectedAt = DateTime.tryParse(data['rejectedAt'] ?? "");
  }

  ApplicantStatus _getStatus(){
    if(rejectedAt != null){
      return ApplicantStatus.rejected;
    } else if(canceledAt != null){
      return ApplicantStatus.canceled;
    } else if(approvedAt != null){
      return ApplicantStatus.approved;
    }
    return ApplicantStatus.applied;
  }
}
