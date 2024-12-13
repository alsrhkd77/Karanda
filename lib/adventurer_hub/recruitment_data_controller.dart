import 'dart:async';
import 'dart:convert';

import 'package:karanda/adventurer_hub/models/recruitment.dart';
import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/common/rest_client.dart';

class RecruitmentDataController {
  Recruitment? _recruitment;
  bool _applied = false;
  int postId;
  bool authenticated;
  final StreamController<Recruitment> _recruitmentController =
      StreamController();

  Stream<Recruitment> get recruitmentStream => _recruitmentController.stream;

  RecruitmentDataController(
      {required this.postId, required this.authenticated}) {
    _getPost();
  }

  Future<void> _getPost() async {
    final response = await RestClient.get(
      "adventurer-hub/post${authenticated ? "/detail" : ""}",
      parameters: {"id": postId.toString()},
    );
    if (response.statusCode == 200) {
      _recruitment = Recruitment.fromData(jsonDecode(response.bodyUTF));
      _recruitmentController.sink.add(_recruitment!);
    }
  }

  Future<bool> changePostStatus() async {
    bool result = false;
    if (_recruitment != null) {
      final response = await RestClient.post(
        "adventurer-hub/post/${_recruitment!.status ? "close" : "open"}",
        body: _recruitment!.id.toString(),
      );
      if(response.statusCode == 200){
        result = bool.tryParse(response.body) ?? false;
        if(result) await _getPost();
      }
    }
    return result;
  }

  Future<bool> changeApplyStatus() async {
    bool result = false;
    if (_recruitment != null && authenticated) {
      final response = await RestClient.post(
        "adventurer-hub/post/${_applied ? "close" : "open"}",
        body: _recruitment!.id.toString(),
      );
      if(response.statusCode == 200){
        result = bool.tryParse(response.body) ?? false;
      }
    }
    return result;
  }

  void dispose() {
    _recruitmentController.close();
  }
}
