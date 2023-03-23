import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:karanda/settings/version_notifier.dart';
import 'package:karanda/widgets/cannot_use_in_web.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:provider/provider.dart';

class AppUpdatePage extends StatefulWidget {
  const AppUpdatePage({Key? key}) : super(key: key);

  @override
  State<AppUpdatePage> createState() => _AppUpdatePageState();
}

class _AppUpdatePageState extends State<AppUpdatePage> {
  bool _loading = false;
  double _downloadProgress = 0;

  @override
  void initState() {
    super.initState();
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
    await Process.start(path, ["-t", "-l", "1000", "/silent"]).then((value) => {});
  }

  Widget buildButton() {
    if (_loading) {
      return Container(
        margin: const EdgeInsets.all(12.0),
        height: 65.0,
        width: 65.0,
        child: const CircularProgressIndicator(),
      );
    }
    return ElevatedButton(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10.0),
        child: const Text('Update'),
      ),
      onPressed: downloadNewVersion,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Scaffold(
        appBar: DefaultAppBar(),
        body: CannotUseInWeb(),
      );
    }
    return Consumer(builder: (context, VersionNotifier versionNotifier, _){
      return Scaffold(
        appBar: const DefaultAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
                margin: const EdgeInsets.all(12.0),
                child: Container(
                  width: 320,
                  margin: const EdgeInsets.all(48.0),
                  child: Column(
                    children: [
                      const Text(
                        'Karanda',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 40.0),
                      ),
                      const SizedBox(
                        height: 22.0,
                      ),
                      Container(
                        margin: const EdgeInsets.all(4.0),
                        child: Text(
                          '현재 버전: ${versionNotifier.currentVersion}',
                          style: const TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(4.0),
                        child: Text(
                          '최신 버전: ${versionNotifier.latestVersion}',
                          style: const TextStyle(fontSize: 18.0),
                        ),
                      ),
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
              versionNotifier.currentVersion != versionNotifier.latestVersion ? buildButton() : const SizedBox(),
            ],
          ),
        ),
      );
    });
  }
}
