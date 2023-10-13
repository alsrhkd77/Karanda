import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FONT { maplestory, notoSansKR, nanumSquareRound }

class SettingsNotifier with ChangeNotifier {
  bool _darkMode = true;

  bool get darkMode => _darkMode;

  FONT _fontFamily = FONT.maplestory;

  FONT get fontFamily => _fontFamily;

  SettingsNotifier() {
    getDataPreference();
  }

  Future<void> getDataPreference() async {
    final prefs = await SharedPreferences.getInstance();
    bool? darkMode = prefs.getBool('darkMode');
    int? font = prefs.getInt('fontFamily');
    _darkMode = darkMode ?? _darkMode;
    _fontFamily = FONT.values[font ?? 0];
    notifyListeners();
  }

  Future<void> saveDataPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setInt('fontFamily', _fontFamily.index);
  }

  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
    saveDataPreference();
  }

  void setFontFamily(FONT value) {
    _fontFamily = value;
    notifyListeners();
    saveDataPreference();
  }
}
