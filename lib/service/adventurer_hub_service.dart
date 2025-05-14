import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/applicant.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/repository/adventurer_hub_repository.dart';
import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/auth_repository.dart';
import 'package:rxdart/rxdart.dart';

import '../model/recruitment.dart';

class AdventurerHubService {
  final AuthRepository _authRepository;
  final AppSettingsRepository _appSettingsRepository;
  final AdventurerHubRepository _adventurerHubRepository;
  final _recruitments = BehaviorSubject<List<Recruitment>>();
  StreamSubscription? _regionSubscription;

  AdventurerHubService({
    required AuthRepository authRepository,
    required AppSettingsRepository appSettingsRepository,
    required AdventurerHubRepository adventurerHubRepository,
  })  : _authRepository = authRepository,
        _appSettingsRepository = appSettingsRepository,
        _adventurerHubRepository = adventurerHubRepository {
    _recruitments.addStream(_adventurerHubRepository.recruitmentsStream);
    if (!kIsWeb && Platform.isWindows) {
      _connectLiveData();
    } else {
      _recruitments.onListen = _connectLiveData;
      _recruitments.onCancel = _disconnectLiveData;
    }
  }

  Stream<User?> get userStream => _authRepository.userStream;

  Stream<List<Recruitment>> get recruitmentsStream => _recruitments.stream;

  void _connectLiveData() {
    if (_appSettingsRepository.region != null) {
      _adventurerHubRepository.getPosts(_appSettingsRepository.region!);
    }
    _regionSubscription = _appSettingsRepository.settingsStream
        .map((settings) => settings.region)
        .distinct()
        .listen(_onRegionUpdate);
  }

  Future<void> _disconnectLiveData() async {
    await _regionSubscription?.cancel();
    _adventurerHubRepository.disconnectLiveChannel();
  }

  void _onRegionUpdate(BDORegion region) {
    _adventurerHubRepository.disconnectLiveChannel();
    _adventurerHubRepository.connectLiveChannel(region);
  }

  Future<Recruitment?> getPost(int postId) async {
    if (_authRepository.authenticated) {
      return await _adventurerHubRepository.getPostDetail(postId);
    }
    return await _adventurerHubRepository.getPost(postId);
  }

  Future<Applicant?> getSubmissionStatus(int postId) async {
    return await _adventurerHubRepository.getSubmissionStatus(postId);
  }

  Future<List<Applicant>> getApplicants(int postId) async {
    return await _adventurerHubRepository.getApplicants(postId);
  }

  Future<Recruitment?> updatePostState(int postId, bool status) async {
    if (status) {
      return await _adventurerHubRepository.openPost(postId);
    } else {
      return await _adventurerHubRepository.closePost(postId);
    }
  }

  Future<Applicant?> join(int postId) async {
    return await _adventurerHubRepository.join(postId);
  }

  Future<Applicant?> cancel(int postId) async {
    return await _adventurerHubRepository.cancel(postId);
  }

  Future<Applicant?> accept(int postId, String applicantId) async {
    return await _adventurerHubRepository.accept(postId, applicantId);
  }

  Future<Applicant?> reject(int postId, String applicantId) async {
    return await _adventurerHubRepository.reject(postId, applicantId);
  }
}
