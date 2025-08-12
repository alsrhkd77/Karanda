import 'package:karanda/data_source/bartering_data_source.dart';
import 'package:karanda/model/bartering/bartering_mastery.dart';
import 'package:karanda/model/bartering/bartering_settings.dart';
import 'package:rxdart/rxdart.dart';

class BarteringRepository {
  final BarteringDataSource _barteringDataSource;
  final _settings = BehaviorSubject<BarteringSettings>();
  final List<BarteringMastery> _mastery = [];

  BarteringRepository({required BarteringDataSource barteringDataSource})
      : _barteringDataSource = barteringDataSource {
    loadSettings();
  }

  Stream<BarteringSettings> get settingsStream => _settings.stream;

  Future<List<BarteringMastery>> mastery() async {
    if (_mastery.isEmpty) {
      _mastery.addAll(await _barteringDataSource.loadMasteryData());
    }
    return _mastery;
  }

  Future<void> loadSettings() async {
    final value = await _barteringDataSource.loadSettings();
    _settings.sink.add(value);
  }

  Future<void> saveSettings(BarteringSettings value) async {
    _settings.sink.add(value);
    await _barteringDataSource.saveSettings(value);
  }
}
