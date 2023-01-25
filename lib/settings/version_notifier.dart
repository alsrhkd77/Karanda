import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;

class VersionNotifier with ChangeNotifier {
  String _currentVersion = '';
  String _latestVersion = '';

  VersionNotifier(GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey) {
    if (!kIsWeb) {
      checkVersion(rootScaffoldMessengerKey);
    }
  }

  Future<void> checkVersion(
      GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey) async {
    _currentVersion = await getCurrentVersion();
    _latestVersion = await getLatestVersion();
    notifyListeners();
    if(_latestVersion.isNotEmpty && _currentVersion != _latestVersion){
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('새로운 버전이 있습니다 ($_latestVersion)'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: '업데이트',
            onPressed: (){
              Get.toNamed('/desktop-app');
            },
            textColor: Theme.of(rootScaffoldMessengerKey.currentContext!).primaryColor,
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16.0),
          backgroundColor: Theme.of(rootScaffoldMessengerKey.currentContext!).snackBarTheme.backgroundColor,
        ),
      );
    }
  }

  Future<String> getCurrentVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<String> getLatestVersion() async {
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/HwanSangYeonHwa/Karanda/main/version.json'));
    Map data = jsonDecode(response.body);
    return data['version']!; //TODO: 예외처리 필요
  }
}
