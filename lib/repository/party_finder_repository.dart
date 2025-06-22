import 'dart:convert';

import 'package:karanda/data_source/party_finder_api.dart';
import 'package:karanda/data_source/web_socket_manager.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/enums/recruitment_category.dart';
import 'package:karanda/model/party_finder_settings.dart';
import 'package:karanda/model/applicant.dart';
import 'package:karanda/model/recruitment.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class PartyFinderRepository {
  final WebSocketManager _webSocketManager;
  final PartyFinderApi _partyFinderApi;
  final _recruitments = BehaviorSubject<List<Recruitment>>();
  final _applicants = BehaviorSubject<List<Applicant>>();
  final _settings = BehaviorSubject<PartyFinderSettings>();

  PartyFinderRepository({
    required WebSocketManager webSocketManager,
    required PartyFinderApi partyFinderApi,
  })  : _webSocketManager = webSocketManager,
        _partyFinderApi = partyFinderApi{
    loadSettings();
    _settings.listen(_onSettingsUpdate);
  }

  Stream<List<Recruitment>> get recruitmentsStream => _recruitments.stream;
  Stream<List<Applicant>> get applicantsStream => _applicants.stream;
  Stream<PartyFinderSettings> get settingsStream => _settings.stream;
  PartyFinderSettings get settings => _settings.valueOrNull ?? PartyFinderSettings();

  void setNotify(bool value){
    final snapshot = _settings.value..notify = value;
    _settings.sink.add(snapshot);
  }

  void updateExcludedCategory(RecruitmentCategory value){
    final snapshot = _settings.value;
    if(snapshot.excludedCategory.contains(value)){
      snapshot.excludedCategory.remove(value);
    } else {
      snapshot.excludedCategory.add(value);
    }
    _settings.sink.add(snapshot);
  }

  Future<void> _onSettingsUpdate(PartyFinderSettings value) async {
    await _partyFinderApi.savePartyFinderSettings(value);
  }

  Future<void> loadSettings() async {
    final value = await _partyFinderApi.loadPartyFinderSettings();
    _settings.sink.add(value);
  }

  void connectLiveChannel(BDORegion region) {
    _webSocketManager.register(
      destination: "/party-finder/REGION/post",
      region: region,
      callback: _liveChannelCallback,
    );
  }

  void disconnectLiveChannel() {
    _webSocketManager.unregister(destination: "/party-finder/REGION/post");
  }

  void connectApplicantsChannel() {
    _webSocketManager.register(
      destination: "/user-private/party-finder/applicants/private",
      callback: _applicantsChannelCallback,
    );
  }

  void disconnectApplicantsChannel() {
    _webSocketManager.unregister(
      destination: "/user-private/party-finder/applicants/private",
    );
  }

  void connectPostDetailChannel(
    int postId,
    void Function(Recruitment) callback,
  ) {
    _webSocketManager.register(
      destination: "/party-finder/post/$postId",
      callback: (frame) {
        if (frame.body?.isNotEmpty ?? false) {
          callback(Recruitment.fromJson(jsonDecode(frame.body!)));
        }
      },
    );
  }

  void disconnectPostDetailChannel(int postId) {
    _webSocketManager.unregister(destination: "/party-finder/post/$postId");
  }

  void connectApplicantListChannel(
      int postId, void Function(Applicant) callback,) {
    _webSocketManager.register(
      destination:
          "/user-private/party-finder/post/$postId/applicants/private",
      callback: (frame) {
        if (frame.body?.isNotEmpty ?? false) {
          callback(Applicant.fromJson(jsonDecode(frame.body!)));
        }
      },
    );
  }

  void disconnectApplicantListChannel(int postId) {
    _webSocketManager.unregister(
      destination:
          "/user-private/party-finder/post/$postId/applicants/private",
    );
  }

  Future<Recruitment?> createPost(RecruitmentPost value) async {
    final result = await _partyFinderApi.createPost(value);
    if (result != null) {
      final snapshot = _recruitments.value..add(result);
      _recruitments.sink.add(snapshot);
    }
    return result;
  }

  Future<Recruitment?> updatePost(Recruitment value) async {
    final result = await _partyFinderApi.updatePost(value);
    if (result != null) {
      final snapshot = _recruitments.value;
      final index = snapshot.indexWhere((post) => post.id == result.id);
      if (index < 0) {
        snapshot.add(result);
      } else {
        snapshot[index] = result;
      }
      _recruitments.sink.add(snapshot);
    }
    return result;
  }

  Future<Recruitment?> openPost(int postId) async {
    return await _partyFinderApi.openPost(postId);
  }

  Future<Recruitment?> closePost(int postId) async {
    return await _partyFinderApi.closePost(postId);
  }

  Future<Applicant?> join(int postId) async {
    return await _partyFinderApi.join(postId);
  }

  Future<Applicant?> cancel(int postId) async {
    return await _partyFinderApi.cancel(postId);
  }

  Future<Applicant?> accept(int postId, String applicantId) async {
    return await _partyFinderApi.accept(postId, applicantId);
  }

  Future<Applicant?> reject(int postId, String applicantId) async {
    return await _partyFinderApi.reject(postId, applicantId);
  }

  Future<void> getUserJoined() async {
    final data = await _partyFinderApi.getUserJoined();
    _applicants.sink.add(data);
  }

  void clearUserJoined(){
    _applicants.sink.add([]);
  }

  Future<void> getPosts(BDORegion region) async {
    final result = await _partyFinderApi.getPosts(region);
    _recruitments.sink.add(result);
  }

  Future<Recruitment?> getPost(int postId) async {
    return await _partyFinderApi.getPost(postId);
  }

  Future<Recruitment?> getPostDetail(int postId) async {
    return await _partyFinderApi.getPostDetail(postId);
  }

  Future<Applicant?> getSubmissionStatus(int postId) async {
    return await _partyFinderApi.getApplicant(postId);
  }

  Future<List<Applicant>> getApplicants(int postId) async {
    return await _partyFinderApi.getApplicants(postId);
  }

  void _liveChannelCallback(StompFrame frame) {
    if (frame.body != null && frame.body!.isNotEmpty) {
      final snapshot = _recruitments.valueOrNull;
      final post = Recruitment.fromJson(jsonDecode(frame.body!));
      if (snapshot == null) {
        _recruitments.sink.add([post]);
      } else {
        final index = snapshot.indexWhere((value) => value.id == post.id);
        if (index < 0) {
          snapshot.add(post);
        } else {
          snapshot[index] = post;
        }
        _recruitments.sink.add(snapshot);
      }
    }
  }

  void _applicantsChannelCallback(StompFrame frame) {
    if (frame.body?.isNotEmpty ?? false) {
      final snapshot = _applicants.valueOrNull;
      final applicant = Applicant.fromJson(jsonDecode(frame.body!));
      if (snapshot == null) {
        _applicants.sink.add([applicant]);
      } else {
        final index =
            snapshot.indexWhere((value) => value.postId == applicant.postId);
        if (index < 0) {
          snapshot.add(applicant);
        } else {
          snapshot[index] = applicant;
        }
        _applicants.sink.add(snapshot);
      }
    }
  }
}
