import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotifier with ChangeNotifier {
  bool _darkMode = true;
  bool get darkMode => _darkMode;


  SettingsNotifier(){
    getDataPreference();
  }

  Future<void> getDataPreference() async {
    final prefs = await SharedPreferences.getInstance();
    bool? darkMode = prefs.getBool('darkMode');
    _darkMode = darkMode ?? _darkMode;
    notifyListeners();
  }

  Future<void> saveDataPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
  }

  void setDarkMode(bool value){
    _darkMode = value;
    notifyListeners();
    saveDataPreference();
  }
}
