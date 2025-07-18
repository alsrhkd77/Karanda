import 'package:karanda/data_source/ship_upgrading_data_source.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_data.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_settings.dart';
import 'package:rxdart/rxdart.dart';

class ShipUpgradingRepository {
  final ShipUpgradingDataSource _dataSource;
  final _settings = BehaviorSubject<ShipUpgradingSettings>();
  final _data = BehaviorSubject<Map<int, ShipUpgradingData>>();


  ShipUpgradingRepository({required ShipUpgradingDataSource dataSource})
      : _dataSource = dataSource;

  Stream<ShipUpgradingSettings> get settingsStream => _settings.stream;
  Stream<Map<int, ShipUpgradingData>> get dataStream => _data.stream;

  Future<void> loadData() async {
    Map<int, ShipUpgradingData> result = {};
    final data = await _dataSource.loadBaseData();
    for(ShipUpgradingData item in data){
      item.stock = await _dataSource.loadUserStock(item.code);
      result[item.code] = item;
    }
    _data.sink.add(result);
  }
  void saveUserStock(int code, int stock){
    final snapshot = _data.value;
    snapshot[code]?.stock = stock;
    _data.sink.add(snapshot);
    _dataSource.saveUserStock(code, stock);
  }

  Future<void> loadSettings() async {
    final value = await _dataSource.loadSettings();
    _settings.sink.add(value);
  }
  Future<void> saveSettings(ShipUpgradingSettings value) async {
    await _dataSource.saveSettings(value);
    _settings.sink.add(value);
  }
}
