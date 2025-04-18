import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:karanda/data_source/app_settings_data_source.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/enums/font.dart';
import 'package:karanda/model/app_settings.dart';
import 'package:rxdart/rxdart.dart';

class AppSettingsRepository {
  late final AppSettingsDataSource _settingsDataSource;
  final _settings = BehaviorSubject<AppSettings>();

  AppSettingsRepository({required AppSettingsDataSource settingsDataSource})
      : _settingsDataSource = settingsDataSource {
    settingsStream.listen(_saveSettings);
  }

  BDORegion? get region => _settings.valueOrNull?.region;

  Stream<AppSettings> get settingsStream => _settings.stream;

  AppSettings get settings => _settings.valueOrNull ?? AppSettings();

  Future<bool> getAppSettings() async {
    final data = await _settingsDataSource.load();
    _settings.sink.add(data ?? AppSettings());
    return data == null;
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

  Future<void> _saveSettings(AppSettings snapshot) async {
    await _settingsDataSource.save(snapshot);
  }
}
