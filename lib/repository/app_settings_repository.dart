import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:karanda/data_source/app_settings_data_source.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/enums/font.dart';
import 'package:karanda/model/app_settings.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

/// 앱 설정 운영 로그.
final _log = Logger('settings');

class AppSettingsRepository {
  /// 창 이동·리사이즈는 드래그 중 초당 수십 회 emit될 수 있다. 매번 저장하지 않고
  /// 조용해질 때까지 기다렸다가 한 번만 저장한다.
  static const Duration _saveDebounce = Duration(milliseconds: 500);

  late final AppSettingsDataSource _settingsDataSource;
  final _settings = BehaviorSubject<AppSettings>();
  Timer? _saveTimer;

  AppSettingsRepository({required AppSettingsDataSource settingsDataSource})
      : _settingsDataSource = settingsDataSource {
    settingsStream.listen(_scheduleSave);
  }

  BDORegion? get region => _settings.valueOrNull?.region;

  Stream<AppSettings> get settingsStream => _settings.stream;

  AppSettings get settings => _settings.valueOrNull ?? AppSettings();

  Future<bool> getAppSettings() async {
    try {
      final data = await _settingsDataSource.load();
      _settings.sink.add(data ?? AppSettings());
      return data == null;
    } catch (e, s) {
      // 로컬 설정 로드 실패(예: 저장 데이터 손상) 시 기본 설정을 적용하고 진행한다.
      // 앱 진입을 막지 않으며, 로드 실패를 첫 실행(웰컴)으로 오인하지 않도록 false를 반환한다.
      _log.warning('Failed to load app settings; applying defaults', e, s);
      _settings.sink.add(AppSettings());
      return false;
    }
  }

  void setThemeMode(ThemeMode value) {
    final snapshot = _settings.value..themeMode = value;
    _settings.sink.add(snapshot);
  }

  void setFont(Font value) {
    final snapshot = _settings.value..font = value;
    _settings.sink.add(snapshot);
  }

  void setRegion(BDORegion value) {
    final snapshot = _settings.value..region = value;
    _settings.sink.add(snapshot);
  }

  void setStartMinimized(bool value) {
    if (!kIsWeb && Platform.isWindows) {
      final snapshot = _settings.value..startMinimized = value;
      _settings.sink.add(snapshot);
    }
  }

  void setUseTrayMode(bool value) {
    if (!kIsWeb && Platform.isWindows) {
      final snapshot = _settings.value..useTrayMode = value;
      _settings.sink.add(snapshot);
    }
  }

  void setWindowSize(Size value) {
    if (!kIsWeb && Platform.isWindows) {
      final snapshot = _settings.value..windowSize = value;
      _settings.sink.add(snapshot);
    }
  }

  void setWindowOffset(Offset value) {
    if (!kIsWeb && Platform.isWindows) {
      final snapshot = _settings.value..windowOffset = value;
      _settings.sink.add(snapshot);
    }
  }

  void _scheduleSave(AppSettings snapshot) {
    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDebounce, () => _saveSettings(snapshot));
  }

  Future<void> _saveSettings(AppSettings snapshot) async {
    await _settingsDataSource.save(snapshot);
  }

  /// 현재 설정이 저장소에 확실히 반영될 때까지 기다린다.
  ///
  /// 평소 저장은 디바운스된 뒤 fire-and-forget으로 처리하므로, 저장이 끝나기 전에
  /// 프로세스가 종료되면 직전 변경(테마·지역·창 크기)이 유실된다.
  /// 종료 직전에 대기 중인 저장을 취소하고 한 번 더 저장해(멱등) 완료를 보장한다.
  Future<void> flush() async {
    _saveTimer?.cancel();
    if (_settings.hasValue) {
      await _saveSettings(_settings.value);
    }
  }
}
