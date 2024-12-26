import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:karanda/adventurer_hub/models/applicant.dart';
import 'package:karanda/adventurer_hub/models/recruitment.dart';
import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/common/rest_client.dart';
import 'package:karanda/common/web_socket_manager/web_socket_manager.dart';
import 'package:karanda/overlay/overlay_manager.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class AdventurerHubDataController {
  Map<String, Recruitment> _posts = {};
  final WebSocketManager _webSocketManager = WebSocketManager();
  final OverlayManager _overlayManager = OverlayManager();

  final StreamController<List<Recruitment>> _postsController =
      StreamController.broadcast();
  final StreamController<Applicant> _applicantsController =
      StreamController.broadcast();

  Stream<List<Recruitment>> get postsStream => _postsController.stream;

  Stream<Applicant> get applicantsStream => _applicantsController.stream;

  static final AdventurerHubDataController _instance =
      AdventurerHubDataController._internal();

  factory AdventurerHubDataController() {
    return _instance;
  }

  AdventurerHubDataController._internal() {
    if (!kIsWeb) {
      postsStream.listen(_sendPostsToOverlay);
    }
    _getPosts();
    _webSocketManager.register(
      destination: "/live-data/user-private/adventurer-hub/applicant",
      callback: _updateApplicant,
    );
    _webSocketManager.register(
      destination: "/live-data/REGION/adventurer-hub/post",
      callback: _updatePost,
    );
  }

  Future<void> _getPosts() async {
    final response = await RestClient.get(
      'adventurer-hub/posts',
      parameters: {'region': 'KR'},
    );
    if (response.statusCode == 200) {
      Map<String, Recruitment> result = {};
      for (Map data in jsonDecode(response.bodyUTF)) {
        Recruitment post = Recruitment.fromData(data);
        result[post.id.toString()] = post;
      }
      _posts = result;
      await _getUserApplied();
      _postsController.sink.add(_posts.values.toList()..sort(_sort));
    }
  }

  Future<void> _getUserApplied() async {
    final response = await RestClient.get('adventurer-hub/user/applied');
    if (response.statusCode == 200) {
      for (Map data in jsonDecode(response.bodyUTF)) {
        Applicant applicant = Applicant.fromData(data);
        if (_posts.containsKey(applicant.postId.toString())) {
          _posts[applicant.postId.toString()]!.applicant = applicant;
        }
        //_postsController.sink.add(_posts.values.toList()..sort(_sort));
      }
    }
  }

  void _updateApplicant(StompFrame frame) {
    if (frame.body != null) {
      Applicant applicant = Applicant.fromData(jsonDecode(frame.body!));
      if (_posts.containsKey(applicant.postId.toString())) {
        _posts[applicant.postId.toString()]!.applicant = applicant;
      }
      _applicantsController.sink.add(applicant);
      _postsController.sink.add(_posts.values.toList()..sort(_sort));
      if (!kIsWeb) {
        _overlayManager.sendData(method: "notification", data: "");
      }
    }
  }

  void _updatePost(StompFrame frame) {
    if (frame.body != null) {
      Recruitment update = Recruitment.fromData(jsonDecode(frame.body!));
      if (_posts.containsKey(update.id.toString())) {
        update.applicant = _posts[update.id.toString()]!.applicant;
        if (update.status && !_posts[update.id.toString()]!.status) {
          if (!kIsWeb) {
            _overlayManager.sendData(
              method: "notification",
              data: "adventurer hub.post opened".tr(args: [update.title]),
            );
          }
        }
      }
      _posts[update.id.toString()] = update;
      _postsController.sink.add(_posts.values.toList()..sort(_sort));
    }
  }

  void _sendPostsToOverlay(List<Recruitment> posts) {
    _overlayManager.sendData(
      method: "adventurer hub",
      data: jsonEncode(posts
          .where((post) => post.status)
          .map((post) => post.toData())
          .toList()),
    );
  }

  void publish() {
    _postsController.sink.add(_posts.values.toList()..sort(_sort));
  }

  int _sort(Recruitment a, Recruitment b) {
    return a.createdAt!.compareTo(b.createdAt!);
  }
}
