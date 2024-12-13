import 'dart:async';
import 'dart:convert';

import 'package:karanda/adventurer_hub/models/recruitment.dart';
import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/common/rest_client.dart';

class AdventurerHubDataController {
  List<Recruitment> posts = [];

  final StreamController<List<Recruitment>> _postsController =
      StreamController.broadcast();

  Stream<List<Recruitment>> get postsStream => _postsController.stream;

  /*static final AdventurerHubDataController _instance =
      AdventurerHubDataController._internal();

  factory AdventurerHubDataController() {
    return _instance;
  }

  AdventurerHubDataController._internal() {
    getPosts();
  }*/

  AdventurerHubDataController() {
    getPosts();
  }

  Future<void> getPosts() async {
    final response = await RestClient.get(
      'adventurer-hub/posts',
      parameters: {'region': 'KR'},
    );
    if (response.statusCode == 200) {
      print(response.bodyUTF);
      List<Recruitment> result = [];
      for (Map data in jsonDecode(response.bodyUTF)) {
        result.add(Recruitment.fromData(data));
      }
      posts = result;
      _postsController.sink.add(posts);
    }
  }

  void publish() {
    _postsController.sink.add(posts);
  }
}
