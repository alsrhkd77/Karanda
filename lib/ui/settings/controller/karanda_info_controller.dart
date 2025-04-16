import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class KarandaInfoController extends ChangeNotifier {
  PackageInfo? data;
  String get version => data?.version ?? "unknown";
  String get buildNumber => data?.buildNumber ?? "unknown";
  String get platform => kIsWeb ? "WEB": Platform.operatingSystem.toUpperCase();

  Future<void> load() async {
    data = await PackageInfo.fromPlatform();
    notifyListeners();
  }
}