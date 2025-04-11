import 'package:karanda/data_source/world_boss_data_source.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/world_boss.dart';
import 'package:karanda/model/world_boss_settings.dart';
import 'package:rxdart/rxdart.dart';

class WorldBossRepository {
  final WorldBossDataSource _worldBossDataSource;
  final _bossData = BehaviorSubject<List<WorldBoss>>();
  final _settings = BehaviorSubject<WorldBossSettings>();

  WorldBossRepository({required WorldBossDataSource worldBossDataSource})
      : _worldBossDataSource = worldBossDataSource {
    settingsStream.listen(_saveSettings);
  }

  WorldBossSettings? get settings => _settings.valueOrNull;

  Stream<List<WorldBoss>> get bossDataStream => _bossData.stream;

  Stream<WorldBossSettings> get settingsStream => _settings.stream;

  Future<void> getBossData(BDORegion region) async {
    final fixed = await _worldBossDataSource.getFixedWorldBoss(region);
    _bossData.sink.add(fixed);
  }

  Future<void> getSettings() async {
    _settings.sink.add(await _worldBossDataSource.loadSettings());
  }
  void addNotificationTime(int value) {
    final snapshot = _settings.value..notificationTime.add(value);
    _settings.sink.add(snapshot);
  }

  void removeNotificationTime(int value) {
    final snapshot = _settings.value..notificationTime.remove(value);
    _settings.sink.add(snapshot);
  }

  void addExcludedBoss(String value) {
    final snapshot = _settings.value..excluded.add(value);
    _settings.sink.add(snapshot);
  }

  void removeExcludedBoss(String value) {
    final snapshot = _settings.value..excluded.remove(value);
    _settings.sink.add(snapshot);
  }

  void setNotify(bool value) {
    final snapshot = _settings.value..notify = value;
    _settings.sink.add(snapshot);
  }

  Future<void> _saveSettings(WorldBossSettings value) async {
    await _worldBossDataSource.saveSettings(value);
    final snapshot = _bossData.valueOrNull;
    if (snapshot != null) {
      _bossData.sink.add(snapshot);
    }
  }
}
