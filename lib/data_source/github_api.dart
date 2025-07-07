import 'dart:convert';
import 'package:http/http.dart' as http;

class GithubApi {
  /// Github api (for release note)
  /// docs: https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28

  final Map<String, String> _headers = {
    "Accept": "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28",
  };

  Future<List> getReleases() async {
    List result = [];
    final http.Response response = await http.get(
      Uri.parse('https://api.github.com/repos/Hammuu1112/Karanda/releases?per_page=80'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      result = jsonDecode(response.body);
    }
    return result;
  }

  Future<Map> getLatest() async {
    Map result = {};
    final http.Response response = await http.get(
      Uri.parse('https://api.github.com/repos/Hammuu1112/Karanda/releases/latest'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      result = jsonDecode(response.body);
    }
    return result;
  }
}