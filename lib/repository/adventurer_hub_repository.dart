import 'dart:convert';

import 'package:karanda/data_source/adventurer_hub_api.dart';
import 'package:karanda/data_source/web_socket_manager.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/applicant.dart';
import 'package:karanda/model/recruitment.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class AdventurerHubRepository {
  final WebSocketManager _webSocketManager;
  final AdventurerHubApi _adventurerHubApi;
  final _recruitments = BehaviorSubject<List<Recruitment>>();

  AdventurerHubRepository({
    required WebSocketManager webSocketManager,
    required AdventurerHubApi adventurerHubApi,
  })  : _webSocketManager = webSocketManager,
        _adventurerHubApi = adventurerHubApi;

  Stream<List<Recruitment>> get recruitmentsStream => _recruitments.stream;

  void connectLiveChannel(BDORegion region) {
    _webSocketManager.register(
      destination: "adventurer-hub/REGION/post",
      region: region,
      callback: _liveChannelCallback,
    );
  }

  void disconnectLiveChannel() {
    _webSocketManager.unregister(destination: "adventurer-hub/REGION/post");
  }

  void connectPostDetailChannel(){}

  void disconnectPostDetailChannel(){}

  void connectApplicantStatusChannel(){}

  void disconnectApplicantStatusChannel(){}

  Future<Recruitment?> createPost(RecruitmentPost value) async {
    final result = await _adventurerHubApi.createPost(value);
    if(result != null){
      final snapshot = _recruitments.value..add(result);
      _recruitments.sink.add(snapshot);
    }
    return result;
  }

  Future<Recruitment?> updatePost(Recruitment value) async {
    final result = await _adventurerHubApi.updatePost(value);
    if(result != null){
      final snapshot = _recruitments.value;
      final index = snapshot.indexWhere((post) => post.id == result.id);
      if(index < 0){
        snapshot.add(result);
      } else {
        snapshot[index] = result;
      }
      _recruitments.sink.add(snapshot);
    }
    return result;
  }

  Future<Recruitment?> openPost(int postId) async {
    return await _adventurerHubApi.openPost(postId);
  }

  Future<Recruitment?> closePost(int postId) async {
    return await _adventurerHubApi.closePost(postId);
  }

  Future<Applicant?> join(int postId) async {
    return await _adventurerHubApi.join(postId);
  }

  Future<Applicant?> cancel(int postId) async {
    return await _adventurerHubApi.cancel(postId);
  }

  Future<Applicant?> accept(int postId, String applicantId) async {
    return await _adventurerHubApi.accept(postId, applicantId);
  }

  Future<Applicant?> reject(int postId, String applicantId) async {
    return await _adventurerHubApi.reject(postId, applicantId);
  }

  Future<void> getPosts(BDORegion region) async {
    final result = await _adventurerHubApi.getPosts(region);
    _recruitments.sink.add(result);
  }

  Future<Recruitment?> getPost(int postId) async {
    return await _adventurerHubApi.getPost(postId);
  }

  Future<Recruitment?> getPostDetail(int postId) async {
    return await _adventurerHubApi.getPostDetail(postId);
  }

  Future<Applicant?> getSubmissionStatus(int postId) async {
    return await _adventurerHubApi.getApplicant(postId);
  }

  Future<List<Applicant>> getApplicants(int postId) async {
    return await _adventurerHubApi.getApplicants(postId);
  }

  void _liveChannelCallback(StompFrame frame) {
    if (frame.body != null && frame.body!.isNotEmpty) {
      final snapshot = _recruitments.valueOrNull;
      final post = Recruitment.fromJson(jsonDecode(frame.body!));
      if(snapshot == null){
        _recruitments.sink.add([post]);
      } else {
        final index = snapshot.indexWhere((value) => value.id == post.id);
        if(index < 0) {
          snapshot.add(post);
        } else {
          snapshot[index] = post;
        }
        _recruitments.sink.add(snapshot);
      }
    }
  }
}
