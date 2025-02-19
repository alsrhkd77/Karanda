import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class WindowsInitializerController extends ChangeNotifier {
  String version = "";

  WindowsInitializerController(){
    _getVersion();
  }

  Future<void> _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    notifyListeners();
  }
}