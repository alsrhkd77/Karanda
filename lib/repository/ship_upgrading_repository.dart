import 'package:karanda/data_source/ship_upgrading_data_source.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_data.dart';
import 'package:karanda/model/ship_upgrading/ship_upgrading_settings.dart';
import 'package:rxdart/rxdart.dart';

class ShipUpgradingRepository {
  final ShipUpgradingDataSource _dataSource;
  final _settings = BehaviorSubject<ShipUpgradingSettings>();
  final _stock = BehaviorSubject<Map<int, int>>();
  final List<ShipUpgradingData> _data = [];


  ShipUpgradingRepository({required ShipUpgradingDataSource dataSource})
      : _dataSource = dataSource{
    loadSettings();
  }

  Stream<ShipUpgradingSettings> get settingsStream => _settings.stream;
  Stream<Map<int, int>> get stockStream => _stock.stream;

  Future<List<ShipUpgradingData>> loadData() async {
    if(_data.isEmpty){
      _data.addAll(await _dataSource.loadBaseData());
    }
    return _data;
  }

  Future<void> loadUserStock() async {
    Map<int, int> result = {};
    if(_data.isEmpty){
      await loadData();
    }
    for(ShipUpgradingData item in _data){
      result[item.code] = await _dataSource.loadUserStock(item.code);
    }
    _stock.sink.add(result);
  }

  Future<void> saveUserStock(int code, int stock) async {
    final snapshot = _stock.value;
    snapshot[code] = stock;
    _stock.sink.add(snapshot);
    await _dataSource.saveUserStock(code, stock);
  }

  Future<void> resetUserStock() async {
    await loadUserStock();
    for(ShipUpgradingData item in _data){
      await saveUserStock(item.code, 0);
    }
    _stock.sink.add({});
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
