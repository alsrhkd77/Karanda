import 'package:karanda/model/lightstone_combination/combination.dart';
import 'package:karanda/repository/lightstone_combination_repository.dart';

/// 테스트용 [LightstoneCombinationRepository] 대역.
///
/// 실제 Repository는 두 개의 DataSource에서 받은 원본 JSON을 조립한다. 필터 로직만 검증하는
/// 이 테스트에서 원본 JSON 스키마까지 흉내 낼 이유가 없으므로 Repository 레벨에서 대체한다.
class FakeLightstoneCombinationRepository
    implements LightstoneCombinationRepository {
  final List<Combination> combinations;

  FakeLightstoneCombinationRepository(this.combinations);

  @override
  Future<List<Combination>> getCombinationData() async => combinations;
}
