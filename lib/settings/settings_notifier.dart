import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FONT { maplestory, notoSansKR, nanumGothic, jua }

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
    if (prefs.containsKey('font')) {
      _fontFamily = FONT.values.byName(prefs.getString('font') ?? 'maplestory');
      prefs.remove('fontFamily');
    } else {
      int? font = prefs.getInt('fontFamily');
      _fontFamily = FONT.values[font ?? 0];
      await prefs.setString('font', _fontFamily.name);
      prefs.remove('fontFamily');
    }
    _darkMode = darkMode ?? _darkMode;
    notifyListeners();
  }

  Future<void> saveDataPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    //await prefs.setInt('fontFamily', _fontFamily.index);
    await prefs.setString('font', _fontFamily.name);
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

  TextTheme? getTextTheme([TextTheme? base]) {
    switch (_fontFamily) {
      case (FONT.notoSansKR):
        return GoogleFonts.notoSansKrTextTheme(base);
      case (FONT.nanumGothic):
        return GoogleFonts.nanumGothicTextTheme(base);
      case (FONT.jua):
        return GoogleFonts.juaTextTheme(base);
      default:
        return null;
    }
  }
}
