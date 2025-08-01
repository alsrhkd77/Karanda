import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/enums/recruitment_join_status.dart';
import 'package:karanda/enums/recruitment_type.dart';
import 'package:karanda/model/applicant.dart';
import 'package:karanda/model/recruitment.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/service/party_finder_service.dart';

class RecruitmentPostController extends ChangeNotifier {
  final PartyFinderService _partyFinderService;
  late final StreamSubscription _user;
  StreamSubscription? _applicants;

  Recruitment? recruitment;
  List<Applicant>? applicants;
  User? user;

  RecruitmentPostController({
    required PartyFinderService partyFinderService,
    required int postId,
  }) : _partyFinderService = partyFinderService {
    _user = _partyFinderService.userStream.listen(_onUserUpdate);
  }

  Applicant? get applicant => applicants?.firstOrNull;

  bool get isOwner =>
      recruitment != null &&
      user != null &&
      recruitment!.author.discordId == user!.discordId;

  bool get isOpened => recruitment?.status ?? false;

  Future<void> getPost({required int postId}) async {
    recruitment = await _partyFinderService.getPost(postId);
    notifyListeners();
    if (recruitment != null) {
      _partyFinderService.connectPostDetailChannel(
        postId,
        _recruitmentChannelCallback,
      );
      if (recruitment!.recruitmentType == RecruitmentType.karandaReservation) {
        _getSubmission();
      }
    }
  }

  Future<bool> changePostStatus() async {
    if (recruitment != null && isOwner) {
      final status = isOpened;
      recruitment = await _partyFinderService.updatePostState(
        recruitment!.id,
        !isOpened,
      );
      notifyListeners();
      return status != isOpened;
    }
    return false;
  }

  Future<bool> join() async {
    if (recruitment != null && user != null && applicant == null) {
      final result = await _partyFinderService.join(recruitment!.id);
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
      final result = await _partyFinderService.cancel(recruitment!.id);
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
          await _partyFinderService.accept(recruitment!.id, applicantId);
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
          await _partyFinderService.reject(recruitment!.id, applicantId);
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
        await _applicants?.cancel();
        applicants = null;
        applicants = await _partyFinderService.getApplicants(recruitment!.id);
        applicants?.sort((a, b) => a.joinAt.compareTo(b.joinAt));
        notifyListeners();
        _partyFinderService.connectApplicantListChannel(
          recruitment!.id,
          _applicantChannelCallback,
        );
      } else {
        _partyFinderService.disconnectApplicantListChannel(recruitment!.id);
        if (applicants == null) {
          _applicants = _partyFinderService.applicantsStream
              .map((items) => items
                  .where((value) => value.postId == recruitment!.id)
                  .toList())
              .distinct()
              .listen(_onApplicantUpdate);
        }
      }
    }
  }

  void _onApplicantUpdate(List<Applicant> value) {
    if (!isOwner) {
      applicants = value;
      notifyListeners();
    }
  }

  void _recruitmentChannelCallback(Recruitment value) {
    recruitment = value..privateDataFrom(recruitment);
    notifyListeners();
  }

  void _applicantChannelCallback(Applicant value) {
    applicants ??= [];
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
    if (recruitment != null) {
      _partyFinderService.disconnectApplicantListChannel(recruitment!.id);
      _partyFinderService.disconnectPostDetailChannel(recruitment!.id);
    }
    _user.cancel();
    _applicants?.cancel();
    super.dispose();
  }
}
