import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'models/horse.dart';
import 'models/horse_equipment.dart';
import 'models/horse_pearl_equipment.dart';
import 'models/horse_spec.dart';
import 'models/horse_status.dart';

class HorseStatusDataController {
  final _selectedBreedController = StreamController<Horse>.broadcast();
  final _selectedEquipmentsController =
      StreamController<Map<String, HorseEquipment>>();
  final _selectedPearlEquipmentsController =
      StreamController<Map<String, bool>>();
  final _resultStatusController = StreamController<HorseStatus>();

  final List<Horse> _breeds = [];
  final Map<String, List<HorseEquipment>> _equipments = {};
  final Map<String, HorsePearlEquipment> _pearlEquipments = {};
  Horse? _selectedBreed;
  final Map<String, HorseEquipment> _selectedEquipments = {};
  final Map<String, bool> _selectedPearlEquipments = {};
  final HorseStatus _resultStatus = HorseStatus();

  Stream<Horse> get selectedBreed => _selectedBreedController.stream;

  Stream<Map<String, HorseEquipment>> get selectedEquipments =>
      _selectedEquipmentsController.stream;

  Stream<Map<String, bool>> get selectedPearlEquipments =>
      _selectedPearlEquipmentsController.stream;

  Stream<HorseStatus> get resultStatus => _resultStatusController.stream;

  List<Horse> get breeds => _breeds;

  Map<String, List<HorseEquipment>> get equipments => _equipments;

  Map<String, HorsePearlEquipment> get pearlEquipments => _pearlEquipments;

  Future<void> getBaseData() async {
    Map data = jsonDecode(
        await rootBundle.loadString('assets/data/horse_status.json'));

    for (String key in data['breed'].keys) {
      _breeds.add(Horse.fromData(data['breed'][key]));
    }
    _selectedBreed = _breeds.first;
    _resultStatus.baseSpec = _selectedBreed!.spec;
    _selectedBreedController.sink.add(_selectedBreed!);

    for (String key in data['equipment'].keys) {
      HorseEquipment item = HorseEquipment.fromData(data['equipment'][key]);
      if (!_equipments.containsKey(item.type)) {
        _equipments[item.type] = [HorseEquipment(type: item.type)];
      }
      _equipments[item.type]?.add(item);
    }
    for (List<HorseEquipment> element in _equipments.values) {
      _selectedEquipments[element.first.type] = element.first;
    }
    _selectedEquipmentsController.sink.add(_selectedEquipments);

    for (String key in data['pearl equipment'].keys) {
      HorsePearlEquipment item =
          HorsePearlEquipment.fromData(data['pearl equipment'][key]);
      if (!_selectedPearlEquipments.containsKey(key)) {
        _selectedPearlEquipments[key] = false;
      }
      _pearlEquipments[key] = item;
    }
    _selectedPearlEquipmentsController.sink.add(_selectedPearlEquipments);
    _resultStatusController.sink.add(_resultStatus);
  }

  void selectBreed(String name) {
    _selectedBreed = _breeds.firstWhere((element) => element.nameEN == name);
    _selectedBreedController.sink.add(_selectedBreed!);

    _resultStatus.baseSpec = _selectedBreed!.spec;
    _resultStatus.calculate();
    _resultStatusController.sink.add(_resultStatus);
  }

  void selectEquipments(String type, String name) {
    if (_equipments.containsKey(type)) {
      int enhancementLevel = _selectedEquipments[type]?.enhancementLevel ?? 0;
      _selectedEquipments[type] =
          _equipments[type]!.firstWhere((element) => element.nameEN == name);
      _selectedEquipments[type]?.enhancementLevel = enhancementLevel;
    }
    _selectedEquipmentsController.sink.add(_selectedEquipments);
    _setAdditionalSpec();
  }

  void setEnhancementLevel(String type, int enhancementLevel) {
    if (_selectedEquipments.containsKey(type)) {
      _selectedEquipments[type]?.enhancementLevel = enhancementLevel;
    }
    _selectedEquipmentsController.sink.add(_selectedEquipments);
    _setAdditionalSpec();
  }

  void setPearlEquipments(String type, bool value) {
    if (_selectedPearlEquipments.containsKey(type)) {
      _selectedPearlEquipments[type] = value;
      _selectedPearlEquipmentsController.sink.add(_selectedPearlEquipments);
      _setAdditionalSpec();
    }
  }

  void _setAdditionalSpec() {
    HorseSpec specModel = HorseSpec();
    for (HorseEquipment item in _selectedEquipments.values) {
      specModel = specModel + item.spec;
    }
    bool pearlSetOption = true; //펄마구 세트 옵션 체크
    for (String key in _selectedPearlEquipments.keys) {
      if (_selectedPearlEquipments[key]!) {
        specModel = specModel + _pearlEquipments[key]!.spec;
      } else {
        pearlSetOption = false;
      }
    }
    if (pearlSetOption) {
      specModel.speed += 1.0;
    }
    _resultStatus.additionalSpec = specModel;
    _resultStatus.calculate();
    _resultStatusController.sink.add(_resultStatus);
  }

  void setLevel(int value) {
    _resultStatus.level = value;
    _resultStatus.calculate();
    _resultStatusController.sink.add(_resultStatus);
  }

  void setSpeed(double value) {
    _resultStatus.finalSpec.speed = value;
    _resultStatus.calculate();
    _resultStatusController.sink.add(_resultStatus);
  }

  void setAccel(double value) {
    _resultStatus.finalSpec.accel = value;
    _resultStatus.calculate();
    _resultStatusController.sink.add(_resultStatus);
  }

  void setTurn(double value) {
    _resultStatus.finalSpec.turn = value;
    _resultStatus.calculate();
    _resultStatusController.sink.add(_resultStatus);
  }

  void setBrake(double value) {
    _resultStatus.finalSpec.brake = value;
    _resultStatus.calculate();
    _resultStatusController.sink.add(_resultStatus);
  }

  void subscribe() {
    if (_selectedBreed != null) {
      _selectedBreedController.sink.add(_selectedBreed!);
    }
  }
}
