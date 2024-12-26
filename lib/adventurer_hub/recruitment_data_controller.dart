import 'dart:async';
import 'dart:convert';

import 'package:karanda/adventurer_hub/adventurer_hub_data_controller.dart';
import 'package:karanda/adventurer_hub/models/applicant.dart';
import 'package:karanda/adventurer_hub/models/recruitment.dart';
import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/common/rest_client.dart';
import 'dart:developer' as developer;

class RecruitmentDataController {
  Recruitment? _recruitment;
  Map<String, Applicant>? _applicants;
  int postId;
  bool authenticated;
  StreamSubscription<Applicant>? _applicantSubscription;
  StreamSubscription<List<Recruitment>>? _recruitmentSubscription;
  final StreamController<Recruitment> _recruitmentController =
      StreamController();
  final StreamController<List<Applicant>> _applicantsController =
      StreamController.broadcast();

  Stream<Recruitment> get recruitmentStream => _recruitmentController.stream;

  Stream<List<Applicant>> get applicantsStream => _applicantsController.stream;

  RecruitmentDataController(
      {required this.postId, required this.authenticated}) {
    _getPost();
  }

  Future<void> _getPost() async {
    final response = await RestClient.get(
      "adventurer-hub/post${authenticated ? "/detail" : ""}",
      parameters: {"postId": postId.toString()},
    );
    if (response.statusCode == 200) {
      _recruitment = Recruitment.fromData(jsonDecode(response.bodyUTF));
      _recruitmentController.sink.add(_recruitment!);
      _recruitmentSubscription =
          AdventurerHubDataController().postsStream.listen(_updateRecruitment);
    }
  }

  Future<void> getApplicants() async {
    if (_applicants == null) {
      Map<String, Applicant> result = {};
      try {
        final response = await RestClient.get(
          "adventurer-hub/post/applicants",
          parameters: {"postId": postId.toString()},
        );
        if (response.statusCode == 200) {
          Map<String, Applicant> map = {};
          for (Map data in jsonDecode(response.bodyUTF)) {
            final applicant = Applicant.fromData(data);
            map[applicant.user.discordId] = applicant;
          }
          result = map;
          _applicantSubscription = AdventurerHubDataController()
              .applicantsStream
              .listen(_updateApplicant);
        }
      } catch (e) {
        developer.log(e.toString());
      } finally {
        _applicants = result;
      }
    }
    _applicantsController.sink.add(_applicants!.values.toList());
  }

  Future<bool> changePostStatus() async {
    bool result = false;
    if (_recruitment != null) {
      final response = await RestClient.post(
        "adventurer-hub/post/${_recruitment!.status ? "close" : "open"}",
        body: {"postId": _recruitment!.id.toString()},
      );
      if (response.statusCode == 200) {
        _recruitment = Recruitment.fromData(jsonDecode(response.bodyUTF));
        _recruitmentController.sink.add(_recruitment!);
        result = true;
      }
    }
    return result;
  }

  Future<bool> changeApplyStatus() async {
    bool result = false;
    if (_recruitment != null && authenticated) {
      String method = _recruitment!.applicant == null ? "apply" : "cancel";
      final response = await RestClient.post(
        "adventurer-hub/post/$method",
        body: {"postId": _recruitment!.id.toString()},
      );
      if (response.statusCode == 200) {
        final applicant = Applicant.fromData(jsonDecode(response.bodyUTF));
        _recruitment!.applicant = applicant;
        _recruitmentController.sink.add(_recruitment!);
        result = true;
      }
    }
    return result;
  }

  Future<void> approve(String target) async {
    final response = await RestClient.post(
      "adventurer-hub/post/approve",
      body: jsonEncode({
        "postId": postId,
        "applicantId": target,
      }),
      json: true,
    );
    if (response.statusCode == 200) {
      Applicant data = Applicant.fromData(jsonDecode(response.bodyUTF));
      _applicants![data.user.discordId] = data;
      _applicantsController.sink.add(_applicants!.values.toList());
    }
  }

  Future<void> reject(String target) async {
    final response = await RestClient.post(
      "adventurer-hub/post/approve",
      body: jsonEncode({
        "postId": postId,
        "applicantId": target,
      }),
      json: true,
    );
    if (response.statusCode == 200) {
      Applicant data = Applicant.fromData(jsonDecode(response.bodyUTF));
      _applicants![data.user.discordId] = data;
      _applicantsController.sink.add(_applicants!.values.toList());
    }
  }

  void updatePost(Recruitment recruitment){
    if(_recruitment?.id == recruitment.id){
      recruitment.applicant = _recruitment!.applicant;
      _recruitment = recruitment;
      _recruitmentController.sink.add(_recruitment!);
    }
  }

  void _updateApplicant(Applicant applicant) {
    if (applicant.postId == postId) {
      if (_recruitment!.applicant?.user.discordId == applicant.user.discordId) {
        _recruitment!.applicant = applicant;
        _recruitmentController.sink.add(_recruitment!);
      } else {
        _applicants ??= {};
        _applicants![applicant.user.discordId] = applicant;
        _applicantsController.sink.add(_applicants!.values.toList());
      }
    }
  }

  void _updateRecruitment(List<Recruitment> posts) {
    if (_recruitment != null && posts.any((item) => item.id == postId)) {
      final post = posts.firstWhere((item) => item.id == postId);
      _recruitment!.status = post.status;
      _recruitment!.currentParticipants = post.currentParticipants;
      _recruitment!.maximumParticipants = post.maximumParticipants;
      _recruitmentController.sink.add(_recruitment!);
    }
  }

  void dispose() {
    _recruitmentController.close();
    _applicantsController.close();
    _applicantSubscription?.cancel();
    _recruitmentSubscription?.cancel();
  }
}
