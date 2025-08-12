import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:karanda/model/bartering/bartering.dart';
import 'package:karanda/model/bartering/bartering_mastery.dart';
import 'package:karanda/model/bartering/bartering_settings.dart';
import 'package:karanda/repository/bartering_repository.dart';

import '../../../model/bartering/ship_profile.dart';

class BarteringParleyController extends ChangeNotifier {
  final BarteringRepository _repository;
  late final StreamSubscription<BarteringSettings> _settings;
  final parleyTextController = TextEditingController()..text = "1000000";
  int parley = 1000000;
  int consumed = 0;
  bool started = false;
  double parleyReductionRate = 0;
  List<BarteringMastery>? mastery;
  BarteringSettings? settings;
  int tradeVoucher = 0;

  /*
   * 미 반영됨 (https://www.naeu.playblackdesert.com/en-US/Forum/ForumTopic/Detail?_topicNo=2315)
   * 떠돌이 상인의 배 - Wandering Merchant Ship
   * 난파된 고대 유적 수송선 - Shipwrecked Anciet Relic Transport Vessel
   * 숄라스 치코의 해적 연합 - Cholace Chiko's Pirate Union
   * 그믐달 길드의 중범선 - Old Moon Carrack
   */

  List<Bartering> locations = [
    Bartering(exchangePoint: "inlandTrades", requiredParley: 14286),
    //내해 교역
    Bartering(exchangePoint: "otherTrades", requiredParley: 14286),
    //일반 교역
    Bartering(exchangePoint: "coin_level4", requiredParley: 21650),
    //주화 교역(4단계)
    Bartering(exchangePoint: "kashuma_halmad", requiredParley: 29430),
    //카슈마, 할마드
    Bartering(exchangePoint: "derko", requiredParley: 36420),
    //더코
    Bartering(exchangePoint: "hakoven", requiredParley: 43780),
    //하코번
    Bartering(exchangePoint: "margoria_low", requiredParley: 46544),
    //마고리아
    Bartering(exchangePoint: "margoria_high", requiredParley: 58180),
    //마고리아
  ];

  BarteringParleyController({required BarteringRepository repository})
      : _repository = repository {
    _settings = _repository.settingsStream.listen(_onSettingsUpdate);
    loadMasteryData();
  }

  int get totalParley => _calcTotalParley();

  Future<void> loadMasteryData() async {
    mastery = await _repository.mastery();
    notifyListeners();
  }

  void updateCount({required int index, required int value}) {
    final str = value > 0 ? value.toString() : '';
    if (locations[index].countTextController.text != str) {
      locations[index].countTextController.text = str;
    }
    locations[index].count = value;
    notifyListeners();
  }

  void increaseCount(int index) {
    if (locations[index].count < 999) {
      final value = locations[index].count + 1;
      updateCount(index: index, value: value);
    }
  }

  void decreaseCount(int index) {
    if (locations[index].count > 0) {
      final value = locations[index].count - 1;
      updateCount(index: index, value: value);
    }
  }

  void applyCount(int index){
    consumed += locations[index].count * locations[index].reducedParley;
    updateCount(index: index, value: 0);
  }

  void onParleyTextUpdate(String? value){
    if(value == null){
      parley = 0;
    } else {
      final parsed = int.tryParse(value) ?? 0;
      parley = parsed;
    }
    final str = parley > 0 ? value.toString() : '';
    if (parleyTextController.text != str) {
      parleyTextController.text = str;
    }
    notifyListeners();
  }

  void start(){
    started = true;
    notifyListeners();
  }

  void resetAll(){
    started = false;
    parley = 1000000;
    parleyTextController.text = "1000000";
    consumed = 0;
    tradeVoucher = 0;
    for(Bartering location in locations){
      location.count = 0;
      location.countTextController.text = '';
    }
    notifyListeners();
  }

  void increaseTradeVoucher() {
    if (tradeVoucher < 99) {
      tradeVoucher = tradeVoucher + 1;
      onParleyTextUpdate((parley + 250000).toString());
      notifyListeners();
    }
  }

  void decreaseTradeVoucher() {
    if (tradeVoucher > 0) {
      tradeVoucher = tradeVoucher - 1;
      onParleyTextUpdate(max(parley - 250000, 0).toString());
      notifyListeners();
    }
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

  int _calcTotalParley(){
    int result = 0;
    for(Bartering location in locations){
      result = result + location.totalParley;
    }
    return result;
  }

  void _onSettingsUpdate(BarteringSettings value) {
    settings = value;
    parleyReductionRate = value.mastery.reductionRate +
        (value.valuePack ? 0.1 : 0) +
        (value.lastSelectedShip.useCleia ? 0.1 : 0);
    for (Bartering location in locations) {
      location.decreasesParley(
        mastery: value.mastery,
        useValuePack: value.valuePack,
        useCleia: value.lastSelectedShip.useCleia,
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    for (Bartering value in locations) {
      value.countTextController.dispose();
    }
    _settings.cancel();
    super.dispose();
  }
}
