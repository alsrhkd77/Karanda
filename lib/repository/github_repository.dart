import 'package:karanda/data_source/github_api.dart';

class GithubRepository {
  final GithubApi _githubApi;

  GithubRepository({required GithubApi githubApi}) : _githubApi = githubApi;

  Future<List<Map>> getReleases() async {
    final List<Map> result = [];
    final data = await _githubApi.getReleases();
    for(Map item in data){
      if(!(item["prerelease"] ?? true)){
        result.add(item);
      }
    }
    return result;
  }
}