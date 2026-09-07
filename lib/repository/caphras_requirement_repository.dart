import 'package:karanda/data_source/caphras_requirement_data_source.dart';
import 'package:karanda/model/caphras_requirement.dart';

/// 장비별 카프라스 누적 개수를 제공한다. 에셋에서 한 번만 읽어 캐시한다.
class CaphrasRequirementRepository {
  final CaphrasRequirementDataSource _dataSource;

  List<CaphrasRequirementGroup>? _groups;

  CaphrasRequirementRepository({
    required CaphrasRequirementDataSource dataSource,
  }) : _dataSource = dataSource;

  Future<List<CaphrasRequirementGroup>> _load() async {
    return _groups ??= await _dataSource.load();
  }

  /// 해당 장비를 [enhancementLevel]에서 카프라스 20단계까지 올릴 때 드는 누적 개수.
  ///
  /// 데이터가 없으면 null이다. 0으로 대체하면 총원가가 과소 계산되어
  /// 엉뚱한 후보가 최저가로 뽑히므로 **반드시 호출 측에서 제외 처리**할 것.
  Future<int?> countOf({
    required int code,
    required int mainCategory,
    required String name,
    required int enhancementLevel,
  }) async {
    final groups = await _load();
    for (final group in groups) {
      if (group.matches(code: code, mainCategory: mainCategory, name: name)) {
        return group.countOf(enhancementLevel);
      }
    }
    return null;
  }
}
