import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:karanda/horse_status/models/horse_equipment_model.dart';
import 'package:karanda/horse_status/models/horse_model.dart';
import 'package:karanda/horse_status/models/horse_pearl_equipment_model.dart';
import 'package:karanda/horse_status/models/horse_spec_model.dart';
import 'package:karanda/horse_status/models/horse_status_model.dart';

class HorseStatusDataController {
  final _selectedBreedController = StreamController<HorseModel>();
  final _selectedEquipmentsController =
      StreamController<Map<String, HorseEquipmentModel>>();
  final _selectedPearlEquipmentsController =
      StreamController<Map<String, bool>>();
  final _horseSpecInputController = StreamController<HorseSpecModel>();
  final _resultStatusController = StreamController<HorseStatusModel>();

  final List<HorseModel> _breeds = [];
  final Map<String, List<HorseEquipmentModel>> _equipments = {};
  final Map<String, HorsePearlEquipmentModel> _pearlEquipments = {};
  late HorseModel _selectedBreed;
  final Map<String, HorseEquipmentModel> _selectedEquipments = {};
  final Map<String, bool> _selectedPearlEquipments = {};
  HorseStatusModel _resultStatus = HorseStatusModel();

  Stream<HorseModel> get selectedBreed => _selectedBreedController.stream;

  Stream<Map<String, HorseEquipmentModel>> get selectedEquipments =>
      _selectedEquipmentsController.stream;

  Stream<Map<String, bool>> get selectedPearlEquipments =>
      _selectedPearlEquipmentsController.stream;

  Stream<HorseSpecModel> get horseSpec => _horseSpecInputController.stream;

  Stream<HorseStatusModel> get resultStatus => _resultStatusController.stream;

  List<HorseModel> get breeds => _breeds;

  Map<String, List<HorseEquipmentModel>> get equipments => _equipments;

  Map<String, HorsePearlEquipmentModel> get pearlEquipments => _pearlEquipments;

  Future<void> getBaseData() async {
    Map data = jsonDecode(
        await rootBundle.loadString('assets/data/horse_status.json'));

    for (String key in data['breed'].keys) {
      _breeds.add(HorseModel.fromData(data['breed'][key]));
    }
    _selectedBreed = _breeds.first;
    _resultStatus.baseSpec = _selectedBreed.spec;
    _selectedBreedController.sink.add(_selectedBreed);

    for (String key in data['equipment'].keys) {
      HorseEquipmentModel item =
          HorseEquipmentModel.fromData(data['equipment'][key]);
      if (!_equipments.containsKey(item.type)) {
        _equipments[item.type] = [HorseEquipmentModel(type: item.type)];
      }
      _equipments[item.type]?.add(item);
    }
    for (List<HorseEquipmentModel> element in _equipments.values) {
      _selectedEquipments[element.first.type] = element.first;
    }
    _selectedEquipmentsController.sink.add(_selectedEquipments);

    for (String key in data['pearl equipment'].keys) {
      HorsePearlEquipmentModel item =
          HorsePearlEquipmentModel.fromData(data['pearl equipment'][key]);
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
    _selectedBreedController.sink.add(_selectedBreed);

    _resultStatus.baseSpec = _selectedBreed.spec;
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

  void _setAdditionalSpec(){
    HorseSpecModel specModel = HorseSpecModel();
    for(HorseEquipmentModel item in _selectedEquipments.values){
      specModel = specModel + item.spec;
    }
    for(String key in _selectedPearlEquipments.keys){
      if(_selectedPearlEquipments[key]!){
        specModel = specModel + _pearlEquipments[key]!.spec;
      }
    }
    _resultStatus.additionalSpec = specModel;
    _resultStatus.calculate();
    _resultStatusController.sink.add(_resultStatus);
  }

  void setLevel(int value){
    _resultStatus.level = value;
    _resultStatus.calculate();
    _resultStatusController.sink.add(_resultStatus);
  }

  void setSpeed(double value){
    _resultStatus.finalSpec.speed = value;
    _resultStatus.calculate();
    _resultStatusController.sink.add(_resultStatus);
  }

  void setAccel(double value){
    _resultStatus.finalSpec.accel = value;
    _resultStatus.calculate();
    _resultStatusController.sink.add(_resultStatus);
  }

  void setTurn(double value){
    _resultStatus.finalSpec.turn = value;
    _resultStatus.calculate();
    _resultStatusController.sink.add(_resultStatus);
  }

  void setBrake(double value){
    _resultStatus.finalSpec.brake = value;
    _resultStatus.calculate();
    _resultStatusController.sink.add(_resultStatus);
  }
}
