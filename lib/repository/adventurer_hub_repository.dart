import 'package:karanda/data_source/adventurer_hub_api.dart';
import 'package:karanda/model/recruitment.dart';
import 'package:rxdart/rxdart.dart';

class AdventurerHubRepository {
  final AdventurerHubApi _adventurerHubApi;
  final _recruitments = BehaviorSubject<List<Recruitment>>();

  AdventurerHubRepository({required AdventurerHubApi adventurerHubApi})
      : _adventurerHubApi = adventurerHubApi;

  Future<Recruitment?> createPost(RecruitmentPost value) async {
    final result = await _adventurerHubApi.createPost(value);
    return result;
  }

  Future<Recruitment?> updatePost(Recruitment value) async {
    final result = await _adventurerHubApi.updatePost(value);
    return result;
  }

  void dispose() {
    _recruitments.close();
  }
}
