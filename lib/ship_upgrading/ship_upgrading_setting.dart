import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ShipUpgradingSetting {
  bool _closeFinishedParts = true;
  bool _showTableHeader = true;
  Map<String, int> _dailyQuest = {};

  Map<String, int> get dailyQuest => _dailyQuest;

  bool get showTableHeader => _showTableHeader;

  set showTableHeader(bool value) {
    _showTableHeader = value;
    save();
  }

  bool get closeFinishedParts => _closeFinishedParts;

  set closeFinishedParts(bool value) {
    _closeFinishedParts = value;
    save();
  }

  void updateDailyQuest(String key, int value){
    if(value <= 0){
      _dailyQuest.remove(key);
    } else {
      _dailyQuest[key] = value;
    }
    save();
  }

  Future<void> save() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'close_finished_parts': _closeFinishedParts,
      'show_table_header': _showTableHeader,
      'daily_quest': _dailyQuest,
    };
    sharedPreferences.setString('ship_upgrading_setting', jsonEncode(data));
  }

  Future<void> load() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    String json = sharedPreferences.getString('ship_upgrading_setting') ?? '';
    if(json.isNotEmpty){
      Map data = jsonDecode(json);
      _closeFinishedParts = data['close_finished_parts'] ?? _closeFinishedParts;
      _showTableHeader = data['show_table_header'] ?? _showTableHeader;
      _dailyQuest = Map<String, int>.from(data['daily_quest'] ?? _dailyQuest);
    }
  }
}