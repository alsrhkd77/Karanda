import 'package:karanda/data_source/ship_upgrading_data_source.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_data.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_settings.dart';

/// 테스트용 [ShipUpgradingDataSource] 대역.
///
/// 실제 구현은 `rootBundle`(에셋 JSON)과 `SharedPreferencesAsync`에 의존한다.
/// Dart는 concrete 클래스도 `implements`로 대체할 수 있으므로 **프로덕션 코드를 수정하지 않고**
/// 실제 `ShipUpgradingRepository`/컨트롤러를 그대로 검증한다.
class FakeShipUpgradingDataSource implements ShipUpgradingDataSource {
  @override
  final String key = "ship-upgrading";

  /// [loadBaseData]가 돌려줄 선박/부품/재료 정의.
  final List<ShipUpgradingData> baseData;

  /// 코드별 보유 수량. [saveUserStock] 결과도 여기에 반영된다.
  final Map<int, int> stock;

  /// [loadSettings]가 돌려줄 설정. 저장이 발생하면 여기에 반영된다.
  ShipUpgradingSettings settings;

  FakeShipUpgradingDataSource({
    required this.baseData,
    Map<int, int>? stock,
    ShipUpgradingSettings? settings,
  })  : stock = stock ?? {},
        settings = settings ?? ShipUpgradingSettings();

  @override
  Future<List<ShipUpgradingData>> loadBaseData() async => baseData;

  @override
  Future<ShipUpgradingSettings> loadSettings() async => settings;

  @override
  Future<void> saveSettings(ShipUpgradingSettings value) async {
    settings = value;
  }

  @override
  Future<int> loadUserStock(int code) async => stock[code] ?? 0;

  @override
  Future<void> saveUserStock(int code, int value) async {
    stock[code] = value;
  }
}
