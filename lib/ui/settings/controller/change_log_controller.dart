import 'package:flutter/foundation.dart';
import 'package:karanda/repository/github_repository.dart';

class ChangeLogController extends ChangeNotifier {
  final GithubRepository _githubRepository;
  String? contents;

  ChangeLogController({required GithubRepository githubRepository})
      : _githubRepository = githubRepository;

  Future<void> getChangeLog() async {
    contents = "# Karanda Change Log \n";
    final value = await _githubRepository.getReleases();
    for (Map item in value) {
      String name = item["name"] ?? '';
      String body = item["body"] ?? '';
      contents = '$contents\n# $name\n$body';
    }
    notifyListeners();
  }
}
