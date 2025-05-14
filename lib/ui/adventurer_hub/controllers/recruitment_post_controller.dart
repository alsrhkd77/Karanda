import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/enums/recruitment_join_status.dart';
import 'package:karanda/enums/recruitment_type.dart';
import 'package:karanda/model/applicant.dart';
import 'package:karanda/model/recruitment.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/service/adventurer_hub_service.dart';

class RecruitmentPostController extends ChangeNotifier {
  final AdventurerHubService _adventurerHubService;
  late final StreamSubscription _user;

  Recruitment? recruitment;
  List<Applicant>? applicants;
  User? user;

  RecruitmentPostController({
    required AdventurerHubService adventurerHubService,
    required int postId,
  }) : _adventurerHubService = adventurerHubService {
    _user = _adventurerHubService.userStream.listen(_onUserUpdate);
  }

  Applicant? get applicant => applicants?.firstOrNull;

  bool get isOwner =>
      recruitment != null &&
      user != null &&
      recruitment!.author.discordId == user!.discordId;

  bool get isOpened => recruitment?.status ?? false;

  Future<void> getPost({required int postId}) async {
    recruitment = await _adventurerHubService.getPost(postId);
    notifyListeners();
    if (recruitment != null &&
        recruitment!.recruitmentType == RecruitmentType.karandaReservation) {
      _getSubmission();
    }
  }

  Future<bool> changePostStatus() async {
    if (recruitment != null && isOwner) {
      recruitment = await _adventurerHubService.updatePostState(
          recruitment!.id, !isOpened);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> join() async {
    if (recruitment != null && user != null && applicant == null) {
      final result = await _adventurerHubService.join(recruitment!.id);
      if (result != null) {
        applicants = [result];
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<bool> cancel() async {
    if (recruitment != null &&
        user != null &&
        applicant?.status == RecruitmentJoinStatus.pending) {
      final result = await _adventurerHubService.cancel(recruitment!.id);
      if (result != null) {
        applicants = [result];
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<bool> accept(String applicantId) async {
    if (recruitment != null) {
      final result =
          await _adventurerHubService.accept(recruitment!.id, applicantId);
      if (result != null) {
        final index = applicants!.indexWhere(
            (value) => value.user.discordId == result.user.discordId);
        applicants![index] = result;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<bool> reject(String applicantId) async {
    if (recruitment != null) {
      final result =
          await _adventurerHubService.reject(recruitment!.id, applicantId);
      if (result != null) {
        final index = applicants!.indexWhere(
            (value) => value.user.discordId == result.user.discordId);
        applicants![index] = result;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<void> _getSubmission() async {
    if (recruitment != null && user != null) {
      if (isOwner) {
        applicants = await _adventurerHubService.getApplicants(recruitment!.id);
        applicants?.sort((a, b) => a.joinAt.compareTo(b.joinAt));
      } else {
        final value =
            await _adventurerHubService.getSubmissionStatus(recruitment!.id);
        if (value != null) {
          applicants = [value];
        }
      }
    }
    notifyListeners();
  }

  void _onApplicantUpdate(Applicant value) {
    if (applicants?.isEmpty ?? true) {
      applicants = [];
    }
    final index = applicants!.indexWhere((item) {
      return item.user.discordId == value.user.discordId;
    });
    if (index < 0) {
      applicants!.add(value);
    } else {
      applicants![index] = value;
    }
    notifyListeners();
  }

  void _onUserUpdate(User? value) {
    user = value;
    notifyListeners();
    _getSubmission();
  }

  @override
  void dispose() {
    _user.cancel();
    super.dispose();
  }
}
