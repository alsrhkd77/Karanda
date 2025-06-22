import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/enums/features.dart';
import 'package:karanda/model/applicant.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/repository/party_finder_repository.dart';
import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/auth_repository.dart';
import 'package:karanda/repository/overlay_repository.dart';
import 'package:rxdart/rxdart.dart';

import '../model/recruitment.dart';

class PartyFinderService {
  final AuthRepository _authRepository;
  final AppSettingsRepository _appSettingsRepository;
  final PartyFinderRepository _partyFinderRepository;
  final OverlayRepository _overlayRepository;
  final _recruitments = BehaviorSubject<List<Recruitment>>();
  final _applicants = BehaviorSubject<List<Applicant>>();
  StreamSubscription? _regionSubscription;
  StreamSubscription? _userSubscription;

  PartyFinderService({
    required AuthRepository authRepository,
    required AppSettingsRepository appSettingsRepository,
    required PartyFinderRepository partyFinderRepository,
    required OverlayRepository overlayRepository,
  })  : _authRepository = authRepository,
        _appSettingsRepository = appSettingsRepository,
        _partyFinderRepository = partyFinderRepository,
        _overlayRepository = overlayRepository {
    _recruitments
        .addStream(_partyFinderRepository.recruitmentsStream.map((value) {
      value.sort(_recruitmentSortOption);
      return value;
    }));
    _applicants.addStream(_partyFinderRepository.applicantsStream);
    if (!kIsWeb && Platform.isWindows) {
      _recruitments.listen(_sendToOverlay);
      _connectLiveRecruitmentData();
      _connectLiveApplicantData();
    } else {
      _recruitments.onListen = _connectLiveRecruitmentData;
      _recruitments.onCancel = _disconnectLiveRecruitmentData;
      _applicants.onListen = _connectLiveApplicantData;
      _applicants.onCancel = _disconnectLiveApplicantData;
    }
  }

  Stream<User?> get userStream => _authRepository.userStream;

  Stream<List<Recruitment>> get recruitmentsStream => _recruitments.stream;

  Stream<List<Applicant>> get applicantsStream => _applicants.stream;

  void _connectLiveRecruitmentData() {
    _regionSubscription = _appSettingsRepository.settingsStream
        .map((settings) => settings.region)
        .distinct()
        .listen(_onRegionUpdate);
  }

  Future<void> _disconnectLiveRecruitmentData() async {
    await _regionSubscription?.cancel();
    _partyFinderRepository.disconnectLiveChannel();
  }

  void _onRegionUpdate(BDORegion region) {
    _partyFinderRepository.getPosts(region);
    _partyFinderRepository.disconnectLiveChannel();
    _partyFinderRepository.connectLiveChannel(region);
  }

  void _connectLiveApplicantData() {
    _userSubscription ??= _authRepository.userStream
        .map((value) => value != null)
        .distinct()
        .listen(_onAuthStatusUpdate);
  }

  Future<void> _disconnectLiveApplicantData() async {
    if (!_applicants.hasListener) {
      await _userSubscription?.cancel();
      _userSubscription = null;
      _partyFinderRepository.clearUserJoined();
      _partyFinderRepository.disconnectApplicantsChannel();
    }
  }

  Future<void> _onAuthStatusUpdate(bool authenticated) async {
    if (authenticated) {
      await _partyFinderRepository.getUserJoined();
      _partyFinderRepository.disconnectApplicantsChannel();
      _partyFinderRepository.connectApplicantsChannel();
    } else {
      _partyFinderRepository.clearUserJoined();
      _partyFinderRepository.disconnectApplicantsChannel();
    }
  }

  void connectPostDetailChannel(
    int postId,
    void Function(Recruitment) callback,
  ) {
    _partyFinderRepository.connectPostDetailChannel(postId, callback);
  }

  void disconnectPostDetailChannel(int postId) {
    _partyFinderRepository.disconnectPostDetailChannel(postId);
  }

  void connectApplicantListChannel(
    int postId,
    void Function(Applicant) callback,
  ) {
    _partyFinderRepository.connectApplicantListChannel(postId, callback);
  }

  void disconnectApplicantListChannel(int postId) {
    _partyFinderRepository.disconnectApplicantListChannel(postId);
  }

  Future<Recruitment?> getPost(int postId) async {
    if (_authRepository.authenticated) {
      return await _partyFinderRepository.getPostDetail(postId);
    }
    return await _partyFinderRepository.getPost(postId);
  }

  Future<Applicant?> getSubmissionStatus(int postId) async {
    return await _partyFinderRepository.getSubmissionStatus(postId);
  }

  Future<List<Applicant>> getApplicants(int postId) async {
    return await _partyFinderRepository.getApplicants(postId);
  }

  Future<Recruitment?> updatePostState(int postId, bool status) async {
    if (status) {
      return await _partyFinderRepository.openPost(postId);
    } else {
      return await _partyFinderRepository.closePost(postId);
    }
  }

  Future<Applicant?> join(int postId) async {
    return await _partyFinderRepository.join(postId);
  }

  Future<Applicant?> cancel(int postId) async {
    return await _partyFinderRepository.cancel(postId);
  }

  Future<Applicant?> accept(int postId, String applicantId) async {
    return await _partyFinderRepository.accept(postId, applicantId);
  }

  Future<Applicant?> reject(int postId, String applicantId) async {
    return await _partyFinderRepository.reject(postId, applicantId);
  }

  void _sendToOverlay(List<Recruitment> value) {
    _overlayRepository.sendToOverlay(
      method: Features.partyFinder.name,
      data: jsonEncode(value
          .where((item) => item.status)
          .map((item) => item.toJson())
          .toList()),
      //data: jsonEncode(value.map((item) => item.toJson()).toList()),
    );
  }

  int _recruitmentSortOption(Recruitment a, Recruitment b) {
    if (a.status == b.status) {
      return b.createdAt.compareTo(a.createdAt);
    } else if (a.status) {
      return -1;
    } else if (b.status) {
      return 1;
    }
    return 0;
  }
}
