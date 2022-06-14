import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;

class AppUpdatePage extends StatefulWidget {
  const AppUpdatePage({Key? key}) : super(key: key);

  @override
  State<AppUpdatePage> createState() => _AppUpdatePageState();
}

class _AppUpdatePageState extends State<AppUpdatePage> {
  String _currentVersion = '';
  String _latestVersion = '';
  bool _loading = false;
  double _downloadProgress = 0;

  @override
  void initState() {
    getCurrentVersion();
    super.initState();
  }

  Future<void> getCurrentVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _currentVersion = packageInfo.version;
    });
  }

  Future<void> getLatestVersion() async {
    setState(() {
      _loading = true;
    });
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/HwanSangYeonHwa/Karanda/main/version.json'));
    Map data = jsonDecode(response.body);
    setState(() {
      _latestVersion = data['version']!;
      _loading = false;
    });
  }

  Future<void> downloadNewVersion() async {
    setState(() {
      _loading = true;
    });
    final Dio dio = Dio();
    String savePath = '${Directory.current.path}/SetupKaranda.exe';
    await dio.download(
        'https://github.com/HwanSangYeonHwa/Karanda/releases/latest/download/SetupKaranda.exe',
        savePath, onReceiveProgress: (received, total) {
      final progress = (received / total) * 100;
      setState(() {
        _downloadProgress = progress;
      });
    });
    await openFile(savePath);
    setState(() {
      _loading = false;
      _downloadProgress = 0;
    });
  }

  Future<void> openFile(String path) async {
    await Process.start(path, ["-t", "-l", "1000"]).then((value) => {});
  }

  Widget buildButton() {
    if (_loading) {
      return Container(
        margin: const EdgeInsets.all(12.0),
        height: 55.0,
        width: 55.0,
        child: const CircularProgressIndicator(),
      );
    } else if (_latestVersion.isEmpty || _currentVersion == _latestVersion) {
      return ElevatedButton(
        child: const Text('Check update'),
        onPressed: getLatestVersion,
      );
    }
    return ElevatedButton(
      child: const Text('Update'),
      onPressed: downloadNewVersion,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Card(
              margin: const EdgeInsets.all(22.0),
              child: Container(
                margin: const EdgeInsets.all(22.0),
                child: Column(
                  children: [
                    const Text('Karanda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),),
                    const SizedBox(height: 8.0,),
                    Text('현재 버전: $_currentVersion'),
                    Text('최신 버전: $_latestVersion'),
                  ],
                ),
              ),
            ),
            _downloadProgress > 0
                ? Container(
                    margin: const EdgeInsets.all(18.0),
                    constraints: const BoxConstraints(
                      maxWidth: 720,
                    ),
                    child: LinearProgressIndicator(
                      color: Colors.green,
                      minHeight: 14.0,
                      value: _downloadProgress,
                    ),
                  )
                : const SizedBox(),
            buildButton(),
          ],
        ),
      ),
    );
  }
}
