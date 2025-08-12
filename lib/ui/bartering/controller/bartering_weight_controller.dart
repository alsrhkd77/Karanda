import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:karanda/model/bartering/bartering.dart';
import 'package:karanda/model/bartering/ship_profile.dart';

import '../../../model/bartering/bartering_settings.dart';
import '../../../repository/bartering_repository.dart';

class BarteringWeightController extends ChangeNotifier {
  final BarteringRepository _repository;
  late final StreamSubscription<BarteringSettings> _settings;
  BarteringSettings? settings;
  final List<Bartering> tradeGoods = [
    Bartering(exchangePoint: "lv1", outputWeight: 100),
    Bartering(exchangePoint: "lv2", outputWeight: 800),
    Bartering(exchangePoint: "lv3", outputWeight: 900),
    Bartering(exchangePoint: "lv4", outputWeight: 1000),
    Bartering(exchangePoint: "lv5", outputWeight: 1000),
    Bartering(exchangePoint: "etc", outputWeight: 0, count: 1),
  ];

  final etcWeightTextController = TextEditingController();

  BarteringWeightController({required BarteringRepository repository})
      : _repository = repository {
    _settings = _repository.settingsStream.listen(_onSettingsUpdate);
  }

  double get totalWeight => _calcTotalWeight();

  void updateCount({required int index, required int value}) {
    final str = value > 0 ? value.toString() : '';
    if (tradeGoods[index].countTextController.text != str) {
      tradeGoods[index].countTextController.text = str;
    }
    tradeGoods[index].count = value;
    notifyListeners();
  }

  void increaseCount(int index) {
    if (tradeGoods[index].count < 999) {
      final value = tradeGoods[index].count + 1;
      updateCount(index: index, value: value);
    }
  }

  void decreaseCount(int index) {
    if (tradeGoods[index].count > 0) {
      final value = tradeGoods[index].count - 1;
      updateCount(index: index, value: value);
    }
  }

  void updateEtcWeight(double value) {
    final str = value > 0 ? value.toString() : '';
    if (etcWeightTextController.text != str) {
      etcWeightTextController.text = str;
    }
    tradeGoods.last.outputWeight = value;
    notifyListeners();
  }

  void resetAll() {
    for (Bartering item in tradeGoods) {
      item.count = 0;
      item.countTextController.text = "";
    }
    tradeGoods.last.count = 1;
    tradeGoods.last.outputWeight = 0;
    etcWeightTextController.text = "";
    notifyListeners();
  }

  void onProfileSelect(ShipProfile? value) {
    if (settings != null && value != null) {
      final BarteringSettings snapshot = settings!;
      snapshot.lastSelectedShipIndex = max(
        0,
        snapshot.shipProfiles.indexWhere((item) {
          return item.name == value.name;
        }),
      );
      _repository.saveSettings(snapshot);
    }
  }

  double _calcTotalWeight() {
    double result = 0;
    for (Bartering item in tradeGoods) {
      result += item.outputWeight * item.count;
    }
    return result;
  }

  void _onSettingsUpdate(BarteringSettings value) {
    settings = value;
    notifyListeners();
  }

  @override
  void dispose() {
    for (Bartering item in tradeGoods) {
      item.countTextController.dispose();
    }
    etcWeightTextController.dispose();
    _settings.cancel();
    super.dispose();
  }
}
