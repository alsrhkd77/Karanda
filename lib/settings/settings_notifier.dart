import 'package:flutter/foundation.dart';

class SettingsNotifier with ChangeNotifier {
  bool _darkMode = true;
  bool get darkMode => _darkMode;

  void setDarkMode(bool value){
    _darkMode = value;
    notifyListeners();
  }
}
