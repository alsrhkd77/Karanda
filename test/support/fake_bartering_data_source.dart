import 'package:karanda/data_source/bartering_data_source.dart';
import 'package:karanda/model/bartering/bartering_mastery.dart';
import 'package:karanda/model/bartering/bartering_settings.dart';

/// 테스트용 [BarteringDataSource] 대역.
///
/// 실제 구현은 `rootBundle`(에셋)과 `SharedPreferencesAsync`에 의존하므로 유닛 테스트에서
/// 그대로 쓸 수 없다. Dart는 concrete 클래스도 `implements`로 인터페이스화할 수 있으므로,
/// **프로덕션 코드를 수정하지 않고** 실제 `BarteringRepository`/컨트롤러를 그대로 검증한다.
class FakeBarteringDataSource implements BarteringDataSource {
  /// [loadSettings]가 돌려줄 설정. 저장이 발생하면 여기에 반영된다.
  BarteringSettings settings;

  /// [loadMasteryData]가 돌려줄 숙련도 테이블.
  final List<BarteringMastery> masteryTable;

  /// [saveSettings] 호출 횟수(영속화가 실제로 일어났는지 확인용).
  int saveCount = 0;

  FakeBarteringDataSource({
    BarteringSettings? settings,
    List<BarteringMastery>? masteryTable,
  })  : settings = settings ?? BarteringSettings(),
        masteryTable = masteryTable ?? [BarteringMastery()];

  @override
  Future<List<BarteringMastery>> loadMasteryData() async => masteryTable;

  @override
  Future<BarteringSettings> loadSettings() async => settings;

  @override
  Future<void> saveSettings(BarteringSettings value) async {
    settings = value;
    saveCount += 1;
  }
}
