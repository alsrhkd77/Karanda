import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/command_line_arguments.dart';
import 'package:karanda/common/http.dart' as http;
import 'package:karanda/overlay/overlay_manager.dart';
import 'package:karanda/world_boss/world_boss_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';

class KarandaInitializer {
  final _percentStreamController = StreamController<double>();
  final _textStreamController = StreamController<String>();
  final _versionStreamController = StreamController<String>();

  Stream<double> get percent => _percentStreamController.stream;

  Stream<String> get task => _textStreamController.stream;

  Stream<String> get version => _versionStreamController.stream;

  KarandaInitializer() {
    _getLatestVersion();
  }

  Future<bool> runTasks(Future<void> authorization) async {
    if (CommandLineArguments.forceUpdate) {
      await _downloadNewVersion();
    }

    int taskNumber = 5;
    if (!CommandLineArguments.skipUpdate) {
      _textStreamController.sink.add("업데이트 확인");
      _percentStreamController.sink.add(0);
      String currentVersion = await _getCurrentVersion();
      _percentStreamController.sink.add(1 / taskNumber);
      String latestVersion = await _getLatestVersion();
      _percentStreamController.sink.add(2 / taskNumber);
      if (currentVersion.isNotEmpty &&
          latestVersion.isNotEmpty &&
          !kDebugMode) {
        if (!currentVersionIsLatest(currentVersion, latestVersion)) {
          await _downloadNewVersion();
        }
        _textStreamController.sink.add("업데이트 대기중");
        return false;
      }
    }
    _percentStreamController.sink.add(3 / taskNumber);

    _textStreamController.sink.add("사용자 인증 정보 확인");
    await authorization;
    _percentStreamController.sink.add(4 / taskNumber);

    _textStreamController.sink.add("오버레이 준비");
    OverlayManager overlayManager = OverlayManager();
    await overlayManager.startOverlay();
    await Future.delayed(const Duration(milliseconds: 1200));

    WorldBossController worldBossController = WorldBossController();
    await worldBossController.init();
    _percentStreamController.sink.add(5 / taskNumber);

    _textStreamController.sink.add("시작하는 중");
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  bool currentVersionIsLatest(String currentVersion, String latestVersion) {
    List<int> current =
        currentVersion.split('.').map((element) => int.parse(element)).toList();
    List<int> latest =
        latestVersion.split('.').map((element) => int.parse(element)).toList();
    if (current[0] < latest[0]) {
      return false;
    } else if (current[1] < latest[1]) {
      return false;
    } else if (current[2] < latest[2]) {
      return false;
    }
    return true;
  }

  Future<String> _getCurrentVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _versionStreamController.sink.add(packageInfo.version);
    return packageInfo.version;
  }

  Future<String> _getLatestVersion() async {
    final response = await http.get(Api.latestVersion);
    Map data = {};
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
    }
    return data['version'] ?? '';
  }

  Future<void> _downloadNewVersion() async {
    _textStreamController.sink.add("다운로드 가능한 업데이트 확인 중");
    final List<String> mirrors = [
      '${Api.latestInstaller}/download/SetupKaranda.exe',
      '${Api.storage}/SetupKaranda.exe',
    ];
    String updatePath = '';
    for (String path in mirrors) {
      final response = await http.head(path);
      if (response.statusCode == 200) {
        updatePath = path;
        break;
      }
    }
    if (updatePath.isNotEmpty) {
      _textStreamController.sink.add("최신 버전 다운로드");
      _percentStreamController.sink.add(0);
      String savePath = '${Directory.current.path}/SetupKaranda.exe';
      final Dio dio = Dio();
      await dio.download(updatePath, savePath,
          onReceiveProgress: (received, total) {
        final progress = received / total;
        _percentStreamController.sink.add(progress);
      });
      _textStreamController.sink.add("업데이트");
      await Future.delayed(const Duration(milliseconds: 500));
      await _openFile(savePath);
    }
  }

  Future<void> _openFile(String path) async {
    await Process.start(path, ["-t", "-l", "1000", "/silent"])
        .then((value) => {});
  }

  void dispose() {
    _percentStreamController.sink.close();
    _textStreamController.sink.close();
    _versionStreamController.sink.close();
  }
}
