import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/model/applicant.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/service/party_finder_service.dart';

import '../../../model/recruitment.dart';

class PartyFinderController extends ChangeNotifier {
  final PartyFinderService _partyFinderService;
  late final StreamSubscription _user;
  late final StreamSubscription _recruitments;
  StreamSubscription? _applicants;

  User? user;
  List<Recruitment>? recruitments;
  List<Applicant>? applicants;

  PartyFinderController({
    required PartyFinderService partyFinderService,
  }) : _partyFinderService = partyFinderService {
    _user = _partyFinderService.userStream.listen(_onUserUpdate);
    _recruitments =
        partyFinderService.recruitmentsStream.listen(_onRecruitmentsUpdate);
  }

  bool get authenticated => user != null;

  List<Recruitment> get myRecruitments =>
      recruitments
          ?.where((data) => data.author.discordId == user?.discordId)
          .take(5)
          .toList() ??
      [];

  List<Applicant> get myApplications =>
      applicants
          ?.where((data) =>
              recruitments?.any((post) => post.id == data.postId) ?? false)
          .take(5)
          .toList() ??
      [];

  List<Recruitment> get appliedPosts =>
      recruitments
          ?.where(
              (data) => myApplications.any((value) => value.postId == data.id))
          .toList() ??
      [];

  void _onUserUpdate(User? value) {
    user = value;
    notifyListeners();
    if (user != null) {
      _applicants =
          _partyFinderService.applicantsStream.listen(_onApplicantsUpdate);
    } else {
      _applicants?.cancel();
      _applicants = null;
    }
  }

  void _onRecruitmentsUpdate(List<Recruitment> value) {
    recruitments = value;
    notifyListeners();
  }

  void _onApplicantsUpdate(List<Applicant> value) {
    value.sort((a, b) => a.joinAt.compareTo(b.joinAt));
    applicants = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _applicants?.cancel();
    _user.cancel();
    _recruitments.cancel();
    super.dispose();
  }
}
