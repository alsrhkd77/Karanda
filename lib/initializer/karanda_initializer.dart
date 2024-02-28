import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:karanda/common/api.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;

class KarandaInitializer {
  final _percentStreamController = StreamController<double>();
  final _textStreamController = StreamController<String>();
  final _versionStreamController = StreamController<String>();

  Stream<double> get percent => _percentStreamController.stream;
  Stream<String> get task => _textStreamController.stream;
  Stream<String> get version => _versionStreamController.stream;

  KarandaInitializer(){
    _getLatestVersion();
  }

  Future<void> runTasks(Future<void> authorization) async {
    int taskNumber = 4;
    _textStreamController.sink.add("업데이트 확인");
    _percentStreamController.sink.add(0);
    String currentVersion = await _getCurrentVersion();
    _percentStreamController.sink.add(1/taskNumber);
    String latestVersion = await _getLatestVersion();
    _percentStreamController.sink.add(2/taskNumber);
    if(currentVersion.isNotEmpty && latestVersion.isNotEmpty && currentVersion != latestVersion){
      await _downloadNewVersion();
    }
    _percentStreamController.sink.add(3/taskNumber);

    _textStreamController.sink.add("사용자 인증 정보 확인");
    await authorization;
    _percentStreamController.sink.add(4/taskNumber);

    _textStreamController.sink.add("시작하는 중");
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<String> _getCurrentVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _versionStreamController.sink.add(packageInfo.version);
    return packageInfo.version;
  }

  Future<String> _getLatestVersion() async {
    final response = await http.get(Uri.parse(Api.latestVersion));
    Map data = {};
    if(response.statusCode == 200){
       data = jsonDecode(response.body);
    }
    return data['version'] ?? '';
  }

  Future<void> _downloadNewVersion() async {
    _textStreamController.sink.add("최신 버전 다운로드");
    _percentStreamController.sink.add(0);
    final Dio dio = Dio();
    String savePath = '${Directory.current.path}/SetupKaranda.exe';
    await dio.download(
        'https://github.com/HwanSangYeonHwa/Karanda/releases/latest/download/SetupKaranda.exe',
        savePath, onReceiveProgress: (received, total) {
      final progress = received / total;
      _percentStreamController.sink.add(progress);
    });

    _textStreamController.sink.add("업데이트");
    await Future.delayed(const Duration(milliseconds: 500));
    await _openFile(savePath);
  }

  Future<void> _openFile(String path) async {
    await Process.start(path, ["-t", "-l", "1000", "/silent"]).then((value) => {});
  }

  void dispose(){
    _percentStreamController.sink.close();
    _textStreamController.sink.close();
    _versionStreamController.sink.close();
  }
}