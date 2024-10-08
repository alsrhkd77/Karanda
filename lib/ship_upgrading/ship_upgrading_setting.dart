import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ShipUpgradingSetting {
  bool _closeFinishedParts = true;
  bool _showTableHeader = true;
  bool _showTotalNeeded = true;
  bool _changeForm = true;
  Map<String, int> _dailyQuest = {
    "5807": 2,
    "5814": 10,
    "5829": 6,
    "5820": 2,
    "5822": 3,
    "5824": 3,
    "5827": 20,
    "5810": 5,
    "5828": 8,
    "5823": 1,
    "5812": 4,
    "5809": 3,
    "5821": 1,
  };

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

  bool get showTotalNeeded => _showTotalNeeded;

  set showTotalNeeded(bool value) {
    _showTotalNeeded = value;
    save();
  }

  bool get changeForm => _changeForm;

  set changeForm(bool value) {
    _changeForm = value;
    save();
  }

  void updateDailyQuest(String key, int value) {
    if (value <= 0) {
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
      'show_total_needed': _showTotalNeeded,
      'daily_quest': _dailyQuest,
      'change_form': _changeForm,
    };
    sharedPreferences.setString('ship_upgrading_setting', jsonEncode(data));
  }

  Future<void> load() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    String json = sharedPreferences.getString('ship_upgrading_setting') ?? '';
    if (json.isNotEmpty) {
      Map data = jsonDecode(json);
      _closeFinishedParts = data['close_finished_parts'] ?? _closeFinishedParts;
      _showTableHeader = data['show_table_header'] ?? _showTableHeader;
      _showTotalNeeded = data['show_total_needed'] ?? _showTotalNeeded;
      _changeForm = data['change_form'] ?? _changeForm;
      _dailyQuest = Map<String, int>.from(data['daily_quest'] ?? _dailyQuest);
    }
  }
}
