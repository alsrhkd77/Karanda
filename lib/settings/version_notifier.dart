import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;

class VersionNotifier with ChangeNotifier {
  String currentVersion = '';
  String latestVersion = '';

  VersionNotifier(GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey) {
    if (!kIsWeb) {
      checkVersion(rootScaffoldMessengerKey);
    }
  }

  Future<void> checkVersion(
      GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey) async {
    currentVersion = await getCurrentVersion();
    latestVersion = await getLatestVersion();
    notifyListeners();
    if(latestVersion.isNotEmpty && currentVersion != latestVersion){
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('새로운 버전이 있습니다 ($latestVersion)'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: '업데이트',
            onPressed: (){
              Get.toNamed('/desktop-app');
            },
            textColor: Colors.blue,
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(24.0),
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
